#!/usr/bin/env python3
"""Analisador corporativo de risco arquitetural (MTA:SA dependency graph).

Requisitos: Python 3.10+, apenas stdlib, saída determinística, escritas atómicas.

Fluxo típico:
  python3 docs/tooling/resource_dependency_scan.py --write
  python3 docs/tooling/architecture_risk_analyzer.py --write

v3.0.x acrescenta: snapshots/histórico, tendência, heatmap blast×degree, smells, ownership, roadmap 7/30/90d.
v3.1.0 encerra governança: métricas C_a/C_e/I (instabilidade Martin), regressão arquitetural vs snapshot
anterior, scorecard executivo (saúde, maturidade, resiliência, mudanças, dívida).
"""

from __future__ import annotations

import argparse
import json
import math
import os
import statistics
import sys
from collections import Counter, defaultdict, deque
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Final, Mapping, MutableMapping, Sequence, TypedDict, cast

# ───────────────────────────────────────────────────────────────────────────────
# Constantes globais tipadas

SCRIPT_DIR: Final[Path] = Path(__file__).resolve().parent
DOCS_DIR: Final[Path] = SCRIPT_DIR.parent
DEFAULT_GRAPH_PATH: Final[Path] = DOCS_DIR / "generated" / "resource-dependency-graph.json"
DEFAULT_JSON_OUT_PATH: Final[Path] = DOCS_DIR / "generated" / "architecture-risk-report.json"
DEFAULT_MD_OUT_PATH: Final[Path] = DOCS_DIR / "generated" / "architecture-risk-report.md"

ANALYZER_VERSION: Final[str] = "3.1.0"
HISTORY_DIR: Final[Path] = DOCS_DIR / "generated" / "history"
HISTORY_MAX_FILES: Final[int] = 50
HISTORY_GLOB_PATTERN: Final[str] = "architecture-risk-*.json"
BOOTSTRAP_PREFIX_LEN: Final[int] = 35
STARTER_DEPENDENTS_THRESHOLD: Final[int] = 10

CORE_FRAMEWORK: Final[frozenset[str]] = frozenset(
    {
        "oMysql",
        "oCore",
        "oStarter",
        "oAccount",
        "oAdmin",
        "oInventory",
        "oVehicle",
        "vila-do-ipiranga-rp",
        "oChat",
        "oAnticheat",
        "oAnticheat2",
        "oCompiler",
        "oFont",
        "oBone",
        "oLoading",
        "oInfobox",
        "oInterface",
    }
)

SCC_MIN_SIZE_PRIO: Final[int] = 3
SCC_MIN_DENSITY_PRIO: Final[float] = 0.40

REG_WEIGHT_NEW_SPOF: Final[float] = 20.0
REG_WEIGHT_NEW_DENSE_CYCLE: Final[float] = 30.0
REG_WEIGHT_BLAST_REGRESSION: Final[float] = 10.0
REG_WEIGHT_INSTABILITY_REGRESSION: Final[float] = 10.0
REGRESSION_SCORE_SATURATION: Final[float] = 45.0


def instability_ratio(ce: float, ca: float) -> float:
    d = ce + ca
    if d <= 0.0:
        return 0.0
    return round(ce / d, 6)


def coupling_zone_kind(
    ca: int,
    ce: int,
    instab: float,
    td: int,
    p75_ca: int,
    p75_ce: int,
    p70_td: int,
) -> str:
    """Árvore determinística: Painful ⊃ Rigid; depois vértices do espectro I."""
    painful_ca_floor = max(4, max(p75_ca, 1))
    painful_ce_floor = max(2, max(min(p75_ce, 12), 1))
    rigid_td_floor = max(6, max(p70_td, 1))

    if td <= 0:
        return "Balanced"
    if ca >= painful_ca_floor and ce >= painful_ce_floor and instab >= 0.52:
        return "Painful"
    if ca >= 3 and ce >= 3 and td >= rigid_td_floor and 0.32 <= instab <= 0.68:
        return "Rigid"
    if instab <= 0.33:
        return "Stable"
    if instab >= 0.67:
        return "Volatile"
    return "Balanced"


def clamp_range(x: float, lo: float, hi: float) -> float:
    return float(min(hi, max(lo, x)))


def band_qualitative_positive(score_0_to_100: float) -> str:
    """Maior = melhor (resiliência, segurança de mudanças)."""
    s = clamp_range(score_0_to_100, 0.0, 100.0)
    if s >= 88.0:
        return "ELITE"
    if s >= 74.0:
        return "STRONG"
    if s >= 58.0:
        return "HEALTHY"
    if s >= 42.0:
        return "WATCH"
    return "CRITICAL"


def band_technical_debt_pressure(pressure_idx_0_to_100: float) -> str:
    """Índice de pressão alto = pior dívida/arregimentação técnica."""
    p = clamp_range(pressure_idx_0_to_100, 0.0, 100.0)
    if p <= 18.0:
        return "ELITE"
    if p <= 34.0:
        return "STRONG"
    if p <= 52.0:
        return "HEALTHY"
    if p <= 70.0:
        return "WATCH"
    return "CRITICAL"


class RemediationPt(TypedDict):
    prioridade: str
    recurso: str
    tipo: str
    razão: str
    acao: str
    impacto: str
    constrangimentos: str


class GraphBundle:
    """Grafo direcionado imutável (vértices e arestas determinísticos)."""

    __slots__ = ("vertices", "edges", "forward", "reverse_adj")

    def __init__(
        self,
        vertices: tuple[str, ...],
        edges: frozenset[tuple[str, str]],
        forward: Mapping[str, frozenset[str]],
        reverse_adj: Mapping[str, frozenset[str]],
    ) -> None:
        self.vertices = vertices
        self.edges = edges
        self.forward = forward
        self.reverse_adj = reverse_adj


# ───────────────────────────────────────────────────────────────────────────────
# I/O & utilitários determinísticos


def load_dependency_graph_strict(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise FileNotFoundError(f"entrada obrigatória em falta: {path}")
    try:
        return cast(dict[str, Any], json.loads(path.read_text(encoding="utf-8")))
    except json.JSONDecodeError as exc:
        raise ValueError(f"JSON inválido ({path}): {exc}") from exc


def atomic_write_text(target: Path, payload: str) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    tmp = target.parent / f".atomic-{target.name}-{os.getpid()}_{id(target)}.tmp"
    tmp.write_text(payload, encoding="utf-8")
    tmp.replace(target)


def percentile_high_floor(sorted_vals: Sequence[int], top_fraction: float) -> int:
    """Índice de corte inferior para incluir cauda alta (~top_fraction do conjunto ascendente)."""
    if not sorted_vals:
        return 0
    f = max(1e-6, min(1.0, top_fraction))
    idx = max(0, math.ceil(len(sorted_vals) * (1.0 - f)) - 1)
    return sorted_vals[idx]


def reachable_exclusive(starts: Sequence[str], adj: Mapping[str, frozenset[str]]) -> frozenset[str]:
    dq = deque(sorted(set(starts)))
    seen: set[str] = set()
    while dq:
        x = dq.popleft()
        if x in seen:
            continue
        seen.add(x)
        for y in sorted(adj.get(x, frozenset())):
            dq.append(y)
    return frozenset(seen)


# ───────────────────────────────────────────────────────────────────────────────
# Construção do grafo & Tarjan SCC O(V+E)


def build_union_graph(raw: Mapping[str, Any]) -> GraphBundle:
    es: set[tuple[str, str]] = set()
    for row in cast(list[Any], raw.get("exports") or []):
        if isinstance(row, dict):
            c, p = row.get("consumer"), row.get("provider")
            if isinstance(c, str) and isinstance(p, str) and c and p:
                es.add((c, p))

    for row in cast(list[Any], raw.get("references") or []):
        if isinstance(row, dict):
            a, b = row.get("from_resource"), row.get("target_resource")
            if isinstance(a, str) and isinstance(b, str) and a and b:
                es.add((a, b))

    for row in cast(list[Any], raw.get("meta_includes") or []):
        if isinstance(row, dict):
            rs, inc = row.get("resource"), row.get("includes")
            if isinstance(rs, str) and isinstance(inc, str) and rs and inc:
                es.add((rs, inc))

    verts: set[str] = set(cast(dict[str, Any], raw.get("resources") or {}).keys())
    for s in cast(list[Any], raw.get("starter_order") or []):
        verts.add(str(s))
    verts.update(u for e in es for u in e)
    vtuple = tuple(sorted(verts))

    fwd: defaultdict[str, set[str]] = defaultdict(set)
    rev: defaultdict[str, set[str]] = defaultdict(set)
    for u, w in sorted(es):
        fwd[u].add(w)
        rev[w].add(u)

    fwd_im: dict[str, frozenset[str]] = {}
    rev_im: dict[str, frozenset[str]] = {}
    for vtx in vtuple:
        fwd_im[vtx] = frozenset(sorted(fwd[vtx]))
        rev_im[vtx] = frozenset(sorted(rev[vtx]))

    edge_frozen = frozenset(sorted(es))
    return GraphBundle(vtuple, edge_frozen, fwd_im, rev_im)


def tarjan_sccs(fwd: Mapping[str, frozenset[str]], vertices: Sequence[str]) -> list[list[str]]:
    index = 0
    stack: list[str] = []
    onstk: set[str] = set()
    idx_map: MutableMapping[str, int] = {}
    low: MutableMapping[str, int] = {}
    comps: list[list[str]] = []

    def strongconnect(v: str) -> None:
        nonlocal index
        idx_map[v] = index
        low[v] = index
        index += 1
        stack.append(v)
        onstk.add(v)
        for w in sorted(fwd.get(v, frozenset())):
            if w not in idx_map:
                strongconnect(w)
                low[v] = min(low[v], low[w])
            elif w in onstk:
                low[v] = min(low[v], idx_map[w])
        if low[v] == idx_map[v]:
            comp: list[str] = []
            while True:
                w = stack.pop()
                onstk.remove(w)
                comp.append(w)
                if w == v:
                    break
            comps.append(sorted(comp))

    for vx in vertices:
        if vx not in idx_map:
            strongconnect(vx)
    comps.sort(key=lambda c: (-len(c), c[0]))
    return comps


def scc_density_internal(edges_f: frozenset[tuple[str, str]], memb: Sequence[str]) -> tuple[int, float]:
    m = frozenset(memb)
    ie = sum(1 for u, v in edges_f if u in m and v in m)
    n = len(memb)
    if n < 2:
        return ie, 0.0
    den = ie / float(n * (n - 1))
    return ie, den


def scc_crit(size: int, rho: float, avg_in_deg: float) -> float:
    return round(size * (0.55 + rho) * (1.0 + math.log1p(max(avg_in_deg, 0.001))), 4)


# ───────────────────────────────────────────────────────────────────────────────
# Métricas de nó


def classify(name: str, ideg: int, odeg: int, td: int, ph: bool, ch: bool) -> str:
    if ideg == 0 and odeg == 0:
        return "Isolated"
    if name in CORE_FRAMEWORK:
        return "Core_Framework"
    if ph and ch and 6 <= td <= 26:
        return "Bridge"
    if ph and odeg >= max(ideg, 4):
        return "Provider"
    if ch and ideg >= max(odeg, 4):
        return "Consumer"
    if abs(ideg - odeg) <= 3 and 6 <= td <= 22:
        return "Bridge"
    if td <= 3 or (odeg <= 2 and td <= 8):
        return "Leaf"
    if ph:
        return "Provider"
    if ch:
        return "Consumer"
    return "General"


def norm_mm(v: Mapping[str, float]) -> dict[str, float]:
    xs = sorted(v.values())
    lo, hi = xs[0], xs[-1]
    span = hi - lo if hi > lo else 1e-9
    return {k: round((float(val) - lo) / span * 100.0, 2) for k, val in sorted(v.items())}


def tier(score: float) -> str:
    if score >= 76:
        return "CRITICAL"
    if score >= 51:
        return "HIGH"
    if score >= 26:
        return "MODERATE"
    return "LOW"


def cycle_mass(v: str, sccs: Sequence[Sequence[str]], fwd: Mapping[str, frozenset[str]]) -> float:
    for comp in sccs:
        if v in comp and len(comp) > 1:
            return float(len(comp))
    return 1.0 if v in fwd and v in fwd[v] else 0.0


# ───────────────────────────────────────────────────────────────────────────────
# Núcleo de análise


@dataclass
class AnalyzeCore:
    resource_metrics: dict[str, dict[str, Any]]
    scc_records: list[dict[str, Any]]
    spof_candidates: list[dict[str, Any]]
    blast_radius: list[dict[str, Any]]
    blast_all_sorted: list[dict[str, Any]]
    hidden_dependencies: dict[str, Any]
    prioritized_large_cycles: int


def run_analysis(raw: Mapping[str, Any], g: GraphBundle) -> AnalyzeCore:
    starter_order = tuple(str(x) for x in cast(list[Any], raw.get("starter_order") or []))
    starters_f = frozenset(starter_order)
    bootstrap_f = frozenset(starter_order[:BOOTSTRAP_PREFIX_LEN])

    fwd = g.forward
    rev = g.reverse_adj
    verts = g.vertices

    in_deg = {x: len(rev[x]) for x in verts}
    out_deg = {x: len(fwd[x]) for x in verts}
    asc_i = sorted(in_deg.values())
    asc_o = sorted(out_deg.values())
    gate_fanin_top5pct = percentile_high_floor(asc_i, 0.05)
    ph_thresh = percentile_high_floor(asc_o, 0.88)
    ch_thresh = percentile_high_floor(asc_i, 0.88)

    t_dep_excl: dict[str, frozenset[str]] = {
        v: reachable_exclusive((v,), rev) - {v} for v in verts
    }
    t_prov_excl: dict[str, frozenset[str]] = {
        v: reachable_exclusive((v,), fwd) - {v} for v in verts
    }

    sccs = tarjan_sccs({k: fwd[k] for k in verts}, verts)
    biggest = max((c for c in sccs), key=len, default=[])

    prioritized_large_cycles = 0
    scc_rows: list[dict[str, Any]] = []

    for comp in sorted(sccs, key=lambda cc: (-len(cc), cc[0])):
        ie, rho = scc_density_internal(g.edges, comp)
        ain = math.fsum(in_deg[m] for m in comp) / max(len(comp), 1)
        crit = scc_crit(len(comp), rho, ain)
        prio = len(comp) >= SCC_MIN_SIZE_PRIO and rho >= SCC_MIN_DENSITY_PRIO
        if prio:
            prioritized_large_cycles += 1
        scc_rows.append(
            {
                "size": len(comp),
                "members": sorted(comp),
                "internal_edges": ie,
                "directed_density": round(rho, 8),
                "criticality_score": crit,
                "prioritized_dense_cycle": prio,
            }
        )

    biggest_fset = frozenset(biggest)
    starter_direct: dict[str, int] = {
        x: sum(1 for pred in sorted(rev[x]) if pred in starters_f) for x in verts
    }

    res_out: dict[str, dict[str, Any]] = {}
    stab_raw: dict[str, float] = {}
    chg_raw: dict[str, float] = {}
    ops_raw: dict[str, float] = {}

    mx_in = max(in_deg.values(), default=1) or 1
    mx_out = max(out_deg.values(), default=1) or 1
    mx_tp = max((len(t_prov_excl[x]) for x in verts), default=1) or 1
    mx_star = max(starter_direct.values(), default=1) or 1
    bn = len(biggest)

    for v in verts:
        ideg_v, odeg_v = in_deg[v], out_deg[v]
        td_v = ideg_v + odeg_v
        cls = classify(v, ideg_v, odeg_v, td_v, odeg_v >= ph_thresh, ideg_v >= ch_thresh)
        tau_start = frozenset(s for s in starters_f if s != v and s in t_dep_excl[v])

        row: dict[str, Any] = {
            "in_degree": ideg_v,
            "out_degree": odeg_v,
            "total_degree": td_v,
            "transitive_dependents": len(t_dep_excl[v]),
            "transitive_providers": len(t_prov_excl[v]),
            "classification": cls,
            "direct_dependents_in_starter": starter_direct[v],
            "transitive_dependents_in_starter": len(tau_start),
        }

        mx_sc = float(max((len(ss) for ss in sccs), default=1)) or 1.0
        cycle_part = cycle_mass(v, sccs, fwd)
        stab_raw[v] = (
            (cycle_part / mx_sc) * 38
            + (in_deg[v] / mx_in) * 32
            + (25 if (v in biggest_fset and bn > 2) else 0)
            + (len(biggest_fset) / max(len(verts), 1)) * 10
        )

        chg_raw[v] = (out_deg[v] / mx_out) * 45 + (len(t_prov_excl[v]) / mx_tp) * 35 + (in_deg[v] / mx_in) * 20
        ops_raw[v] = (
            (starter_direct[v] / mx_star) * 42
            + (25 if v in bootstrap_f else 0)
            + (18 if v in CORE_FRAMEWORK else 0)
            + (in_deg[v] / mx_in) * 33
        )

        res_out[v] = row

    stab_s = norm_mm(stab_raw)
    chg_s = norm_mm(chg_raw)
    ops_s = norm_mm(ops_raw)
    composite: dict[str, float] = {}

    for v in verts:
        comp_score = stab_s[v] * 0.42 + chg_s[v] * 0.33 + ops_s[v] * 0.25
        composite[v] = round(comp_score, 2)
        res_out[v]["stability_score"] = stab_s[v]
        res_out[v]["change_risk_score"] = chg_s[v]
        res_out[v]["operational_risk_score"] = ops_s[v]
        res_out[v]["composite"] = composite[v]
        res_out[v]["tier"] = tier(composite[v])

    spofs: list[dict[str, Any]] = []

    for v in verts:
        reasons: list[str] = []
        if in_deg[v] >= gate_fanin_top5pct and in_deg[v] > 0:
            reasons.append("top_5pct_fan_in")
        if v in bootstrap_f:
            reasons.append("starter_prefix_first_35")
        if v in biggest_fset and len(biggest_fset) > 1:
            reasons.append("largest_strongly_connected_component")
        if starter_direct[v] > STARTER_DEPENDENTS_THRESHOLD:
            reasons.append(f"starter_direct_dependents_gt_{STARTER_DEPENDENTS_THRESHOLD}")
        if str(res_out[v]["classification"]) == "Core_Framework":
            reasons.append("core_framework_classified")

        if reasons:
            spofs.append(
                {
                    "resource": v,
                    "reasons": sorted(set(reasons)),
                    "severity_key": round(
                        math.log1p(in_deg[v]) * math.log1p(starter_direct[v] + 1),
                        4,
                    ),
                    "in_degree": in_deg[v],
                    "direct_dependents_in_starter": starter_direct[v],
                }
            )

    spofs.sort(key=lambda r: (-float(r["severity_key"]), -int(r["in_degree"]), cast(str, r["resource"])))

    blasts: list[dict[str, Any]] = []
    for v in verts:
        tdep = t_dep_excl[v]
        tr_starter = sum(1 for s in starters_f if s != v and s in tdep)
        cascade = math.log1p(starter_direct[v] + 1) * math.log1p(tr_starter + 1) * math.log1p(len(tdep) + 1)
        blasts.append(
            {
                "resource": v,
                "direct_dependents_in_starter": starter_direct[v],
                "transitive_dependents_in_starter": tr_starter,
                "cascade_score": round(float(cascade), 6),
            }
        )
    blasts.sort(
        key=lambda b: (-float(cast(float | int, b["cascade_score"])), cast(str, b["resource"]))
    )
    blasts_all = list(blasts)

    verts_ord = sorted(verts)
    ca_list_sorted = sorted(in_deg[v] for v in verts_ord)
    ce_list_sorted = sorted(out_deg[v] for v in verts_ord)
    td_vals_coupling = sorted(in_deg[v] + out_deg[v] for v in verts_ord)
    p75_ca_c = percentile_high_floor(ca_list_sorted or [0], 0.25)
    p75_ce_c = percentile_high_floor(ce_list_sorted or [0], 0.25)
    p70_td_c = percentile_high_floor(td_vals_coupling or [0], 0.30)
    blast_lookup = {cast(str, bx["resource"]): float(cast(float | int, bx["cascade_score"])) for bx in blasts_all}

    for vtx in verts_ord:
        ca_v = int(in_deg[vtx])
        ce_v = int(out_deg[vtx])
        td_cv = ca_v + ce_v
        inst_v = instability_ratio(float(ce_v), float(ca_v))
        res_out[vtx]["cascade_score"] = round(blast_lookup[vtx], 6)
        res_out[vtx]["afferent_coupling"] = ca_v
        res_out[vtx]["efferent_coupling"] = ce_v
        res_out[vtx]["instability"] = inst_v
        res_out[vtx]["coupling_zone"] = coupling_zone_kind(
            ca_v, ce_v, float(inst_v), td_cv, p75_ca_c, p75_ce_c, p70_td_c
        )

    ud_rows = cast(list[Any], raw.get("undeclared_dependencies") or [])
    cons_ud: defaultdict[str, int] = defaultdict(int)
    prov_ud: defaultdict[str, int] = defaultdict(int)
    crt_sample: list[dict[str, Any]] = []

    hazards: list[dict[str, Any]] = []
    for u in ud_rows:
        if not isinstance(u, dict):
            continue
        k = cast(str | None, u.get("kind"))
        kind_l = k.lower() if isinstance(k, str) else ""
        if "starter" in kind_l:
            hazards.append(cast(dict[str, Any], u))
    hazards.sort(key=lambda h: -(int(cast(int | float, h.get("occurrence_count"))) or 0))

    for u in ud_rows:
        if not isinstance(u, dict):
            continue
        c = cast(str | None, u.get("consumer"))
        p = cast(str | None, u.get("provider"))
        oc = int(cast(int | float, u.get("occurrence_count")) or 0)
        if isinstance(c, str) and c:
            cons_ud[c] += oc
        if isinstance(p, str) and p:
            prov_ud[p] += oc
        if cast(bool | None, u.get("critical_path")):
            crt_sample.append(
                {
                    "consumer": u.get("consumer"),
                    "provider": u.get("provider"),
                    "occurrence_count": u.get("occurrence_count"),
                    "kind": u.get("kind"),
                }
            )
    crt_sample.sort(key=lambda r: -(int(cast(int | float, r.get("occurrence_count"))) or 0))

    hidden_block: dict[str, Any] = {
        "ranked_undeclared_consumers": [
            {"resource": rn, "occurrence_aggregate": ag}
            for rn, ag in sorted(cons_ud.items(), key=lambda t: (-t[1], t[0]))[:40]
        ],
        "ranked_undeclared_providers": [
            {"resource": rn, "occurrence_aggregate": ag}
            for rn, ag in sorted(prov_ud.items(), key=lambda t: (-t[1], t[0]))[:40]
        ],
        "critical_path_couplings_sample": crt_sample[:30],
        "startup_hazard_samples": [
            {
                "consumer": h.get("consumer"),
                "provider": h.get("provider"),
                "occurrence_count": h.get("occurrence_count"),
                "kind": h.get("kind"),
            }
            for h in hazards[:32]
        ],
    }

    scc_rows.sort(
        key=lambda r: (-float(cast(float, r["criticality_score"])), -int(cast(int, r["size"])))
    )

    return AnalyzeCore(
        resource_metrics=res_out,
        scc_records=scc_rows,
        spof_candidates=spofs,
        blast_radius=blasts[:25],
        blast_all_sorted=blasts_all,
        hidden_dependencies=hidden_block,
        prioritized_large_cycles=prioritized_large_cycles,
    )


# ───────────────────────────────────────────────────────────────────────────────
# Remediação & montagem do relatório


def build_remediation_pt(ac: AnalyzeCore) -> list[RemediationPt]:
    seen: set[str] = set()
    buckets: dict[str, list[RemediationPt]] = {"P0": [], "P1": [], "P2": [], "P3": []}

    def put(key: str, row: RemediationPt) -> None:
        if key in seen:
            return
        seen.add(key)
        buckets.setdefault(str(row["prioridade"]), []).append(row)

    for sp in ac.spof_candidates[:14]:
        rv = cast(str, sp["resource"])
        put(
            f"P0|{rv}",
            {
                "prioridade": "P0",
                "recurso": rv,
                "tipo": "ponto_unico_falha",
                "razão": ", ".join(cast(list[str], sp["reasons"])),
                "acao": "Reduzir blast radius com fachadas explícitas, plano restart em staging, telemetria alvo.",
                "impacto": "Elevado — coordenação multi-recurso.",
                "constrangimentos": "Arranque sequencial MTA; ciclos acoplam janelas de restart.",
            },
        )

    for scc in ac.scc_records:
        if not cast(bool | None, scc.get("prioritized_dense_cycle")):
            continue
        mem = ",".join(cast(list[str], scc["members"]))
        put(
            f"P1|SCC|{mem[:80]}",
            {
                "prioridade": "P1",
                "recurso": mem,
                "tipo": "componente_fortemente_conexo_denso",
                "razão": f"ρ={round(float(cast(float, scc['directed_density'])),4)} n={scc['size']} arcos={scc['internal_edges']}",
                "acao": "Introduzir camadas / mediador de contratos; dissolver exports mútuos incrementalmente.",
                "impacto": "Muito elevado — toca muitos módulos.",
                "constrangimentos": "Preservar chamadas síncronas existentes durante migração.",
            },
        )

    for row in cast(list[dict[str, Any]], ac.hidden_dependencies.get("critical_path_couplings_sample") or [])[:12]:
        c = str(row.get("consumer") or "")
        p = str(row.get("provider") or "")
        put(
            f"P1|hid|{c}|{p}",
            {
                "prioridade": "P1",
                "recurso": f"{c}↔{p}",
                "tipo": "dependencia_oculta_critica",
                "razão": f"ocorrências={row.get('occurrence_count')} kind={row.get('kind')}",
                "acao": "Declarar `<include>` ou reordenar `oStarter`; wrappers opcionais.",
                "impacto": "Médio — risco regressão arranque.",
                "constrangimentos": "Validar um recurso de cada vez em ambiente prod-like.",
            },
        )

    seen_b: set[str] = set()
    p2c = 0
    for br in ac.blast_radius:
        r = cast(str, br["resource"])
        if r in seen_b:
            continue
        seen_b.add(r)
        put(
            f"P2|{r}",
            {
                "prioridade": "P2",
                "recurso": r,
                "tipo": "blast_radius",
                "razão": f"cascade_score={br['cascade_score']} τ_starter={br['transitive_dependents_in_starter']} direto_starter={br['direct_dependents_in_starter']}",
                "acao": "Smoke scripted pós-deploy; monitorização health checks para este vizinho.",
                "impacto": "Médio — contenção operacional.",
                "constrangimentos": "Evitar refactor divergente multi-equipa mesmo hub.",
            },
        )
        p2c += 1
        if p2c >= 12:
            break

    for blk in cast(list[dict[str, Any]], ac.hidden_dependencies.get("ranked_undeclared_providers") or [])[:10]:
        ag = blk.get("occurrence_aggregate")
        if isinstance(ag, (int, float)) and ag < 60:
            continue
        rs = cast(str, blk["resource"])
        put(
            f"P3|P|{rs}",
            {
                "prioridade": "P3",
                "recurso": rs,
                "tipo": "provedor_escuro_fanout",
                "razão": f"peso undeclared agregado={ag}",
                "acao": "Documentar superfície mínima de exports + metadados explícitos.",
                "impacto": "Baixo–médio.",
                "constrangimentos": "Coordenar consumidores antes de mudar contratos públicos.",
            },
        )

    return buckets["P0"] + buckets["P1"] + buckets["P2"] + buckets["P3"]


# ───────────────────────────────────────────────────────────────────────────────
# v3.0 — Histórico, tendência, heatmap, smells, ownership, roadmap


def history_snapshots_sorted_newest_first() -> list[Path]:
    """Ficheiros de histórico ordenados por nome (timestamp lexical = cronológico)."""
    if not HISTORY_DIR.is_dir():
        return []
    names = sorted(
        HISTORY_DIR.glob(HISTORY_GLOB_PATTERN),
        key=lambda p: p.name,
        reverse=True,
    )
    return names


def load_history_snapshot(path: Path) -> dict[str, Any]:
    raw_txt = path.read_text(encoding="utf-8")
    return cast(dict[str, Any], json.loads(raw_txt))


def load_newest_history_snapshot() -> tuple[dict[str, Any] | None, str | None]:
    """Último snapshot guardado (basename) e conteúdo; serve de linha de base para tendência."""
    snaps = history_snapshots_sorted_newest_first()
    if not snaps:
        return None, None
    p = snaps[0]
    return load_history_snapshot(p), p.name


def prune_history_snapshots_retention(max_keep: int = HISTORY_MAX_FILES) -> None:
    HISTORY_DIR.mkdir(parents=True, exist_ok=True)
    paths = sorted(
        HISTORY_DIR.glob(HISTORY_GLOB_PATTERN),
        key=lambda p: p.name,
        reverse=True,
    )
    for old in paths[max_keep:]:
        try:
            old.unlink()
        except OSError:
            pass


def infer_composite_mean_top12(doc: Mapping[str, Any] | None) -> float | None:
    if doc is None:
        return None
    es = doc.get("executive_summary")
    if isinstance(es, dict):
        v = es.get("composite_mean_top12")
        if isinstance(v, (int, float)):
            return round(float(v), 2)
    tcr = cast(list[Any], doc.get("top_critical_resources") or [])
    if not tcr:
        return None
    comps: list[float] = []
    for row in tcr[:12]:
        if isinstance(row, dict) and isinstance(row.get("composite"), (int, float)):
            comps.append(float(row["composite"]))
    if not comps:
        return None
    return round(statistics.mean(comps), 2)


def spof_resource_set(doc: Mapping[str, Any]) -> frozenset[str]:
    out: set[str] = set()
    for row in cast(list[Any], doc.get("spof_candidates") or []):
        if isinstance(row, dict):
            rs = row.get("resource")
            if isinstance(rs, str) and rs:
                out.add(rs)
    return frozenset(out)


def prioritized_cycle_signatures(doc: Mapping[str, Any]) -> frozenset[str]:
    sigs: set[str] = set()
    for row in cast(list[Any], doc.get("strongly_connected_components") or []):
        if not isinstance(row, dict):
            continue
        if not cast(bool | None, row.get("prioritized_dense_cycle")):
            continue
        mem = cast(list[str] | None, row.get("members"))
        if isinstance(mem, list) and mem:
            sigs.add(",".join(sorted(str(m) for m in mem)))
    return frozenset(sigs)


def risk_trend_from_delta(delta: float) -> str:
    if delta <= -5.0:
        return "IMPROVING"
    if delta >= 5.0:
        return "DEGRADING"
    return "STABLE"


SMELL_RANK: Final[dict[str, int]] = {
    "CRITICAL": 4,
    "HIGH": 3,
    "MODERATE": 2,
    "LOW": 1,
}


PREFIX_CONFIDENCE_HIGH: Final[int] = 5
PREFIX_CONFIDENCE_MEDIUM: Final[int] = 2


def build_trend_analysis(
    current_partial: Mapping[str, Any],
    previous_doc: Mapping[str, Any] | None,
) -> dict[str, Any]:
    cur_mean = infer_composite_mean_top12(current_partial)
    prv_mean = infer_composite_mean_top12(previous_doc)

    delta: float | None
    if previous_doc is None:
        delta = None
        rt = "STABLE"
    elif cur_mean is not None and prv_mean is not None:
        delta = round(float(cur_mean) - float(prv_mean), 2)
        rt = risk_trend_from_delta(float(delta))
    else:
        delta = None
        rt = "STABLE"

    cur_sp = spof_resource_set(current_partial)
    prv_sp = spof_resource_set(previous_doc) if previous_doc else frozenset()

    sig_c = prioritized_cycle_signatures(current_partial)
    sig_p = prioritized_cycle_signatures(previous_doc) if previous_doc else frozenset()

    new_spofs = sorted(cur_sp - prv_sp)
    resolved_spofs = sorted(prv_sp - cur_sp)
    new_cycles = sorted(sig_c - sig_p)
    resolved_cycles = sorted(sig_p - sig_c)

    return {
        "score_delta": delta,
        "new_spofs": new_spofs,
        "resolved_spofs": resolved_spofs,
        "new_cycles": new_cycles,
        "resolved_cycles": resolved_cycles,
        "risk_trend": rt,
    }


def median_or_zero(vals: Sequence[float]) -> float:
    if not vals:
        return 0.0
    return round(float(statistics.median(vals)), 6)


def build_risk_heatmap(ac: AnalyzeCore, g: GraphBundle) -> dict[str, Any]:
    cascades = [float(b["cascade_score"]) for b in ac.blast_all_sorted]
    couplings_td = sorted(
        int(cast(int | float, ac.resource_metrics[v]["total_degree"])) for v in sorted(g.vertices)
    )
    med_c = median_or_zero(cascades)
    med_td = float(median_or_zero([float(x) for x in couplings_td]))

    blast_lookup = {cast(str, b["resource"]): float(b["cascade_score"]) for b in ac.blast_all_sorted}

    q_keys = (
        "high_blast_high_coupling",
        "high_blast_low_coupling",
        "low_blast_high_coupling",
        "low_blast_low_coupling",
    )

    quadrant_resources: dict[str, list[dict[str, Any]]] = {k: [] for k in q_keys}
    by_resource: dict[str, str] = {}

    for v in sorted(g.vertices):
        m = ac.resource_metrics[v]
        csc = blast_lookup[v]
        td = float(cast(int | float, m["total_degree"]))
        hi_bl = csc >= med_c
        hi_cp = td >= med_td
        if hi_bl and hi_cp:
            qk = "high_blast_high_coupling"
        elif hi_bl:
            qk = "high_blast_low_coupling"
        elif hi_cp:
            qk = "low_blast_high_coupling"
        else:
            qk = "low_blast_low_coupling"

        quadrant_resources[qk].append(
            {
                "resource": v,
                "cascade_score": round(csc, 6),
                "total_degree": int(td),
                "composite": m["composite"],
            }
        )
        by_resource[v] = qk

    def top_n(qk: str, n: int = 10) -> list[dict[str, Any]]:
        rows = list(quadrant_resources[qk])
        rows.sort(
            key=lambda r: (-float(cast(float | int, r["composite"])), cast(str, r["resource"]))
        )
        return rows[:n]

    quadrants_export: dict[str, Any] = {}
    titles = {
        "high_blast_high_coupling": "HIGH blast + HIGH coupling",
        "high_blast_low_coupling": "HIGH blast + LOW coupling",
        "low_blast_high_coupling": "LOW blast + HIGH coupling",
        "low_blast_low_coupling": "LOW blast + LOW coupling",
    }

    for qk in q_keys:
        quadrants_export[qk] = {
            "title": titles[qk],
            "resources": quadrant_resources[qk],
            "top_10": top_n(qk, 10),
        }

    return {
        "blast_median_threshold": med_c,
        "coupling_median_threshold_total_degree": med_td,
        "quadrants": quadrants_export,
        "by_resource": by_resource,
    }


def build_architectural_smells(
    ac: AnalyzeCore,
    raw: Mapping[str, Any],
    g: GraphBundle,
    exec_sum: Mapping[str, Any],
) -> list[dict[str, Any]]:
    starter_order = tuple(str(x) for x in cast(list[Any], raw.get("starter_order") or []))
    starters_f = frozenset(starter_order)
    bootstrap_f = frozenset(starter_order[:BOOTSTRAP_PREFIX_LEN])

    gate_fi = int(cast(int | float, exec_sum.get("fan_in_gate_top_5pct") or 0))
    verts = sorted(g.vertices)
    td_vals_sorted = sorted(
        int(cast(int | float, ac.resource_metrics[v]["total_degree"])) for v in verts
    )
    td_hi_coupling = int(percentile_high_floor(td_vals_sorted, 0.15)) if td_vals_sorted else 0
    tp_vals_sorted = sorted(
        int(cast(int | float, ac.resource_metrics[v]["transitive_providers"])) for v in verts
    )
    tp_hi = percentile_high_floor(tp_vals_sorted or [0], 0.12)

    odors: list[dict[str, Any]] = []

    for v in verts:
        rm = ac.resource_metrics[v]
        ideg = int(cast(int | float, rm["in_degree"]))
        td = int(cast(int | float, rm["total_degree"]))
        comp = float(cast(float | int, rm["composite"]))
        chrisk = float(cast(float | int, rm["change_risk_score"]))
        tprov = int(cast(int | float, rm["transitive_providers"]))

        # God Resource
        if ideg >= max(gate_fi, 1) and td >= max(td_hi_coupling, 1):
            if comp >= 71 and ideg >= gate_fi:
                sev_g = "CRITICAL"
            elif comp >= 51 or ideg >= gate_fi + 2:
                sev_g = "HIGH"
            else:
                sev_g = "MODERATE"
            odors.append(
                {
                    "type": "God Resource",
                    "resource": v,
                    "severity": sev_g,
                    "rationale": f"Elevado fan-in (in={ideg}) e acoplamento de grau ({td}); funil de dependências potencialmente monolítico.",
                    "recommendation": "Extrair façade explícito, subdividir superfície pública, reduzir entradas implícitas do starter.",
                }
            )

        # Fragile Core
        if v in CORE_FRAMEWORK and comp >= 50:
            odors.append(
                {
                    "type": "Fragile Core",
                    "resource": v,
                    "severity": "HIGH" if comp < 71 else "CRITICAL",
                    "rationale": f"Marcado como CORE_FRAMEWORK com composite alto ({comp:.1f}); alterações cascateiam.",
                    "recommendation": "Congelar contratos públicos, testes smoke no arranque, versões semver internas nos exports.",
                }
            )

        # Change Amplifier
        if chrisk >= 76.0 and tprov >= tp_hi and tprov >= 6:
            odors.append(
                {
                    "type": "Change Amplifier",
                    "resource": v,
                    "severity": "MODERATE" if chrisk < 86 else "HIGH",
                    "rationale": f"change_risk elevado ({chrisk:.1f}) e fan-out de providers transitivos elevado ({tprov}) face ao conjunto.",
                    "recommendation": "Isolar contratos atrás de recurso médio estável; reduzir fan-out obrigatório em PRs grandes.",
                }
            )

        # Startup Bottleneck
        if v in bootstrap_f:
            sdp = int(cast(int | float, rm["direct_dependents_in_starter"]))
            tau = len(frozenset(s for s in starters_f if s != v and s in reachable_exclusive((v,), g.reverse_adj)))
            if sdp >= STARTER_DEPENDENTS_THRESHOLD or tau >= STARTER_DEPENDENTS_THRESHOLD:
                odors.append(
                    {
                        "type": "Startup Bottleneck",
                        "resource": v,
                        "severity": "HIGH" if sdp >= STARTER_DEPENDENTS_THRESHOLD * 2 else "MODERATE",
                        "rationale": f"No prefixo inicial do starter ({len(bootstrap_f)} primeiros): dependentes starter diretos={sdp}, efectivos Starter↔Σ={tau}.",
                        "recommendation": "Reordenar oStarter onde seguro; dividir ciclo obrigatório de arranque; validar timings com scan --write.",
                    }
                )

    # Cyclic Cluster (uma entrada por SCC prioritário denso — recurso âncora = primeiro lexical)
    for srow in ac.scc_records:
        if not cast(bool | None, srow.get("prioritized_dense_cycle")):
            continue
        mem = cast(list[str], srow["members"])
        anchor = min(mem)
        odors.append(
            {
                "type": "Cyclic Cluster",
                "resource": anchor,
                "severity": "CRITICAL" if int(cast(int, srow["size"])) >= 9 else "HIGH",
                "rationale": f"SCC prioritário denso size={srow['size']} ρ={round(float(cast(float, srow['directed_density'])),4)}.",
                "recommendation": "Introduzir mediator/direções unidimensionais sobre exports cruzados; extrair subgraph em módulos menores.",
            }
        )

    # Hidden Dependency Hub
    hid = cast(list[Any], ac.hidden_dependencies.get("ranked_undeclared_consumers") or [])
    hid_p = cast(list[Any], ac.hidden_dependencies.get("ranked_undeclared_providers") or [])
    for bucket, label_hub in (
        (hid[:18], "consumer"),
        (hid_p[:18], "provider"),
    ):
        for blk in bucket:
            if not isinstance(blk, dict):
                continue
            ag = blk.get("occurrence_aggregate")
            rs = blk.get("resource")
            if not isinstance(rs, str) or rs == "":
                continue
            if not isinstance(ag, (int, float)) or int(ag) < 72:
                continue
            odors.append(
                {
                    "type": "Hidden Dependency Hub",
                    "resource": rs,
                    "severity": "HIGH" if int(ag) >= 180 else "MODERATE",
                    "rationale": f"Agregado undeclared elevado ({label_hub} weight={ag}) — acoplamento implícito transversal.",
                    "recommendation": "Declarar includes/meta; documentar contrato mínimo; alinhar ordem de arranque com resource_dependency_scan.",
                }
            )

    odors.sort(
        key=lambda o: (
            -SMELL_RANK.get(cast(str, o["severity"]), 0),
            -float(ac.resource_metrics.get(cast(str, o["resource"]), {}).get("composite", 0) or 0)
            if cast(str, o["resource"]) in ac.resource_metrics
            else 0.0,
            cast(str, o["type"]),
            cast(str, o["resource"]),
        )
    )
    return odors


def build_ownership_suggestions(vertices: Sequence[str]) -> list[dict[str, Any]]:
    pairs: list[tuple[str, str]] = []
    for v in sorted(set(vertices)):
        if "_" in v:
            dom = v.split("_", 1)[0].strip().lower() or "platform-core"
        else:
            dom = "platform-core"
        pairs.append((v, dom))

    ctr = Counter(d for _, d in pairs)
    rows: list[dict[str, Any]] = []
    for v, dom in pairs:
        c = ctr[dom]
        if c >= PREFIX_CONFIDENCE_HIGH:
            conf = "HIGH"
        elif c >= PREFIX_CONFIDENCE_MEDIUM:
            conf = "MEDIUM"
        else:
            conf = "LOW"
        suggested = f"{dom}-team" if dom != "platform-core" else "platform-core"
        rows.append(
            {
                "resource": v,
                "suggested_team": suggested,
                "domain": dom,
                "ownership_confidence": conf,
            }
        )

    rows.sort(key=lambda r: (cast(str, r["resource"]),))
    return rows


def remediation_priority_rank(p: str) -> int:
    return {"P0": 4, "P1": 3, "P2": 2, "P3": 1}.get(p.upper(), 0)


def roadmap_effort_reduction(prio: str) -> tuple[str, str]:
    p = prio.upper()
    if p == "P0":
        return "XS–S", "HIGH"
    if p == "P1":
        return "S–M", "HIGH"
    if p == "P2":
        return "M–L", "MEDIUM"
    return "L–XL", "LOW"


def build_refactoring_roadmap(rem: Sequence[RemediationPt]) -> dict[str, list[dict[str, Any]]]:
    buckets: dict[str, list[dict[str, Any]]] = {"immediate_7d": [], "near_term_30d": [], "strategic_90d": []}
    for row in sorted(
        rem,
        key=lambda r: (
            -remediation_priority_rank(cast(str, r["prioridade"])),
            cast(str, r["recurso"]),
        ),
    ):
        prio = cast(str, row["prioridade"]).upper()
        effort, reduction = roadmap_effort_reduction(prio)

        horizon: str | None = None
        if prio in {"P0", "P1"}:
            hk = "immediate_7d"
            horizon = "Immediate (7 dias)"
        elif prio == "P2":
            hk = "near_term_30d"
            horizon = "Near Term (30 dias)"
        else:
            hk = "strategic_90d"
            horizon = "Strategic (90 dias)"

        buckets[hk].append(
            {
                "title": f"{horizon}: {cast(str, row['tipo']).replace('_', ' ')}",
                "target_resource": cast(str, row["recurso"]),
                "rationale": cast(str, row["razão"]),
                "estimated_effort": effort,
                "expected_risk_reduction": reduction,
            }
        )

    return {
        "horizon_labels": {
            "immediate_7d": "Immediate (7 dias)",
            "near_term_30d": "Near Term (30 dias)",
            "strategic_90d": "Strategic (90 dias)",
        },
        **buckets,
    }


def ca_ce_from_legacy_metrics(row: Mapping[str, Any]) -> tuple[int, int]:
    """Compatível snapshots v3.0.x antes de Ca/Ce explícitos (usa in/out degree)."""
    if "afferent_coupling" in row and "efferent_coupling" in row:
        return int(cast(int | float, row["afferent_coupling"])), int(
            cast(int | float, row["efferent_coupling"])
        )
    return int(cast(int | float, row.get("in_degree") or 0)), int(cast(int | float, row.get("out_degree") or 0))


def instability_from_legacy_metrics(row: Mapping[str, Any]) -> float:
    if isinstance(row.get("instability"), (int, float)):
        return float(row["instability"])
    ca, ce = ca_ce_from_legacy_metrics(row)
    return instability_ratio(float(ce), float(ca))


def cascade_from_legacy_metrics(row: Mapping[str, Any]) -> float:
    cs = row.get("cascade_score")
    return float(cast(int | float, cs)) if isinstance(cs, (int, float)) else 0.0


def semver_triplet(version_obj: object) -> tuple[int, int, int]:
    t = str(version_obj or "").strip().lstrip("v").split("+", 1)[0]
    parts = t.split(".")
    nums: list[int] = []

    def seg_at(i: int) -> None:
        if i >= len(parts):
            nums.append(0)
            return
        acc = "".join(ch for ch in parts[i].strip() if ch.isdigit())
        nums.append(int(acc) if acc else 0)

    seg_at(0)
    seg_at(1)
    seg_at(2)
    return nums[0], nums[1], nums[2]


def regression_blast_cascade_comparison_enabled(previous_doc: Mapping[str, Any] | None) -> bool:
    """Snapshots v3.0.x não incluem cascata útil por recurso; omitir regressão blast para baseline legado."""
    if not isinstance(previous_doc, dict):
        return False
    mv = previous_doc.get("metadata")
    if not isinstance(mv, dict):
        return False
    return semver_triplet(mv.get("analyzer_version")) >= (3, 1, 0)


def resource_metrics_blob(doc: Mapping[str, Any] | None) -> dict[str, dict[str, Any]]:
    rm = cast(dict[str, Any] | None, doc.get("resource_metrics")) if doc else None
    if not isinstance(rm, dict):
        return {}
    return cast(dict[str, dict[str, Any]], {str(k): cast(dict[str, Any], v) for k, v in rm.items() if isinstance(v, dict)})


def coupling_rank_projection(resource: str, m: Mapping[str, Any]) -> dict[str, Any]:
    ca, ce = ca_ce_from_legacy_metrics(m)
    td = ca + ce
    return {
        "resource": resource,
        "afferent_coupling": ca,
        "efferent_coupling": ce,
        "instability": float(m["instability"]) if isinstance(m.get("instability"), (int, float)) else instability_from_legacy_metrics(m),
        "coupling_zone": str(m.get("coupling_zone") or "Balanced"),
        "total_degree": td,
        "composite": round(float(cast(int | float, m["composite"])), 2),
        "cascade_score": round(cascade_from_legacy_metrics(m), 6),
    }


def build_coupling_analysis(ac: AnalyzeCore, vertices: Sequence[str]) -> dict[str, Any]:
    verts = sorted(set(vertices))
    rows_src: list[tuple[str, dict[str, Any]]] = [(v, ac.resource_metrics[v]) for v in verts]

    unstable = sorted(
        (coupling_rank_projection(v, m) for v, m in rows_src),
        key=lambda r: (-float(r["instability"]), -int(r["total_degree"]), cast(str, r["resource"])),
    )[:20]

    rigid_zone = sorted(
        (coupling_rank_projection(v, m) for v, m in rows_src if str(m.get("coupling_zone")) == "Rigid"),
        key=lambda r: (-int(r["total_degree"]), -float(r["composite"]), cast(str, r["resource"])),
    )[:20]

    coupled = sorted(
        (coupling_rank_projection(v, m) for v, m in rows_src),
        key=lambda r: (-int(r["total_degree"]), -float(r["composite"]), cast(str, r["resource"])),
    )[:20]

    return {
        "top_most_unstable": unstable,
        "top_most_rigid": rigid_zone,
        "top_most_coupled": coupled,
    }


def build_architectural_regression_detection(
    previous_doc: Mapping[str, Any] | None,
    current_rm: Mapping[str, Mapping[str, Any]],
    new_spofs: Sequence[str],
    new_cycle_signatures: Sequence[str],
    comparison_available: bool,
    blast_metric_compare_allowed: bool,
) -> dict[str, Any]:
    if not comparison_available:
        return {
            "regression_events": [],
            "regression_score": 0.0,
            "regression_severity": "NONE",
            "raw_penalty_units": 0.0,
            "comparison_available": False,
            "blast_cascade_comparison_enabled": False,
        }

    events: list[dict[str, Any]] = []
    pre = resource_metrics_blob(previous_doc)

    for sp_name in sorted(set(str(x) for x in new_spofs)):
        events.append(
            {
                "type": "NEW_SPOF",
                "resource": sp_name,
                "delta_detail": "+candidatura SPOF vs snapshot anterior",
            }
        )

    for sig in sorted(set(str(x) for x in new_cycle_signatures)):
        anchor_parts = sorted([p.strip() for p in sig.split(",") if p.strip()])
        anchor = (anchor_parts[0][:128] if anchor_parts else "") if sig else ""
        events.append(
            {
                "type": "NEW_PRIORITIZED_DENSE_CYCLE",
                "resource": anchor,
                "cycle_signature": sig,
                "delta_detail": "SCC prioritário denso novo vs baseline",
            }
        )

    blast_regressions = 0
    inst_regressions = 0
    verts_all = sorted(set(current_rm.keys()) | set(pre.keys()))

    for v in verts_all:
        pv = pre.get(v)
        cv = current_rm.get(v)
        if pv is None or cv is None:
            continue
        p_cascade = cascade_from_legacy_metrics(pv)
        c_cascade = cascade_from_legacy_metrics(cv)
        p_i = instability_from_legacy_metrics(pv)
        c_i = instability_from_legacy_metrics(cv)

        blast_jump = False
        if blast_metric_compare_allowed and isinstance(pv.get("cascade_score"), (int, float)) and isinstance(cv.get("cascade_score"), (int, float)):
            if p_cascade > 1e-6:
                blast_jump = c_cascade > p_cascade * 1.2 + 1e-9
            else:
                blast_jump = c_cascade >= 8.5
        if blast_jump:
            pct = round(100.0 * (c_cascade / p_cascade - 1.0), 2) if p_cascade > 1e-6 else 100.0
            events.append(
                {
                    "type": "BLAST_RADIUS_REGRESSION",
                    "resource": v,
                    "previous_cascade": round(p_cascade, 6),
                    "current_cascade": round(c_cascade, 6),
                    "delta_detail": f"↑>{pct}% vs baseline" if p_cascade > 1e-6 else "elevado novo vs cascata ~0 anterior",
                }
            )
            blast_regressions += 1

        if c_i > p_i + 0.15 + 1e-9:
            events.append(
                {
                    "type": "INSTABILITY_REGRESSION",
                    "resource": v,
                    "previous_instability": p_i,
                    "current_instability": c_i,
                    "delta_detail": "Δ instability > +0.15",
                }
            )
            inst_regressions += 1

    raw = (
        REG_WEIGHT_NEW_SPOF * float(len(set(new_spofs)))
        + REG_WEIGHT_NEW_DENSE_CYCLE * float(len(set(new_cycle_signatures)))
        + REG_WEIGHT_BLAST_REGRESSION * float(blast_regressions)
        + REG_WEIGHT_INSTABILITY_REGRESSION * float(inst_regressions)
    )

    regression_score = round(
        min(100.0, (100.0 * raw / max(raw + REGRESSION_SCORE_SATURATION, REGRESSION_SCORE_SATURATION)) if raw > 0.0 else 0.0),
        2,
    )

    if raw <= 1e-9 and len(events) == 0:
        severity = "NONE"
    elif regression_score <= 24.5:
        severity = "LOW"
    elif regression_score <= 48.5:
        severity = "MODERATE"
    elif regression_score <= 71.5:
        severity = "HIGH"
    else:
        severity = "CRITICAL"

    type_order = {
        "NEW_SPOF": 0,
        "NEW_PRIORITIZED_DENSE_CYCLE": 1,
        "BLAST_RADIUS_REGRESSION": 2,
        "INSTABILITY_REGRESSION": 3,
    }
    events_sorted = sorted(
        events,
        key=lambda ev: (
            type_order.get(str(ev.get("type")), 99),
            str(ev.get("resource")),
            str(ev.get("cycle_signature", "")),
        ),
    )

    return {
        "regression_events": events_sorted,
        "regression_score": regression_score,
        "regression_severity": severity,
        "raw_penalty_units": round(raw, 4),
        "comparison_available": True,
        "blast_cascade_comparison_enabled": blast_metric_compare_allowed,
    }


def count_critical_smells(smells: Sequence[dict[str, Any]]) -> int:
    return sum(1 for s in smells if str(s.get("severity")) == "CRITICAL")


def mean_metrics_top12(ac: AnalyzeCore, top_resources: Sequence[Mapping[str, Any]]) -> tuple[float, float, float]:
    """Médias stability/change/op sobre até 12 vértices do ranking top_critical."""
    acc_s: list[float] = []
    acc_c: list[float] = []
    acc_o: list[float] = []
    for row in top_resources[:12]:
        rname = cast(str | None, row.get("resource"))
        if not rname or rname not in ac.resource_metrics:
            continue
        m = ac.resource_metrics[rname]
        acc_s.append(float(cast(float | int, m["stability_score"])))
        acc_c.append(float(cast(float | int, m["change_risk_score"])))
        acc_o.append(float(cast(float | int, m["operational_risk_score"])))
    n = max(1, len(acc_s))
    return (
        round(statistics.mean(acc_s), 4) if acc_s else 0.0,
        round(statistics.mean(acc_c), 4) if acc_c else 0.0,
        round(statistics.mean(acc_o), 4) if acc_o else 0.0,
    )


def build_executive_scorecard(
    composite_mean_top12: float,
    regression_analysis: Mapping[str, Any],
    smells: Sequence[dict[str, Any]],
    exec_sum: Mapping[str, Any],
    ac: AnalyzeCore,
    top_crit: Sequence[Mapping[str, Any]],
) -> dict[str, Any]:
    crit_n = count_critical_smells(cast(list[dict[str, Any]], list(smells)))
    comp = clamp_range(composite_mean_top12, 0.0, 100.0)
    reg_scr = clamp_range(float(cast(int | float, regression_analysis.get("regression_score") or 0.0)), 0.0, 100.0)

    architecture_health_score = clamp_range(
        100.0 - (comp * 0.40) - (reg_scr * 0.30) - (float(crit_n) * 4.0),
        0.0,
        100.0,
    )
    architecture_health_score_r = round(architecture_health_score, 2)

    vertices_n = max(1, int(cast(int | float, exec_sum.get("vertices") or 0)))
    spof_cnt = int(cast(int | float, exec_sum.get("spof_candidate_count") or 0))
    ud_rows = int(cast(int | float, exec_sum.get("undeclared_rows") or 0))

    ms, mc, mo = mean_metrics_top12(ac, top_crit)

    opr = clamp_range(100.0 - min(76.0, float(spof_cnt) * 1.05) - mo * 0.36 - min(35.0, ud_rows / 18.5), 0.0, 100.0)
    ch_safe = clamp_range(100.0 - mc * 0.93 - reg_scr * 0.08, 0.0, 100.0)
    td_pressure_idx = clamp_range(comp * 0.48 + reg_scr * 0.34 + min(76.0, float(ud_rows) / float(vertices_n) * 3.05), 0.0, 100.0)

    return {
        "architecture_health_score": architecture_health_score_r,
        "risk_maturity_level": band_qualitative_positive(architecture_health_score),
        "operational_resilience": band_qualitative_positive(opr),
        "change_safety": band_qualitative_positive(ch_safe),
        "technical_debt_pressure": band_technical_debt_pressure(td_pressure_idx),
    }


def assemble_report(
    payload: Mapping[str, Any],
    g: GraphBundle,
    ac: AnalyzeCore,
    previous_snapshot: Mapping[str, Any] | None = None,
    previous_snapshot_basename: str | None = None,
) -> dict[str, Any]:
    rem = build_remediation_pt(ac)
    harden = [x for x in rem if x["prioridade"] in {"P0", "P1", "P2"}]
    refactor = [x for x in rem if x["prioridade"] == "P3"]

    verts = sorted(g.vertices)
    in_vals = sorted(int(cast(int | float, ac.resource_metrics[v]["in_degree"])) for v in verts)

    starter_order = tuple(str(x) for x in cast(list[Any], payload.get("starter_order") or []))
    ud_n = len(cast(list[Any], payload.get("undeclared_dependencies") or []))

    top_crit = sorted(
        (
            {
                "resource": v,
                "composite": ac.resource_metrics[v]["composite"],
                "tier": ac.resource_metrics[v]["tier"],
                "stability_score": ac.resource_metrics[v]["stability_score"],
                "change_risk_score": ac.resource_metrics[v]["change_risk_score"],
                "operational_risk_score": ac.resource_metrics[v]["operational_risk_score"],
                "classification": ac.resource_metrics[v]["classification"],
            }
            for v in verts
        ),
        key=lambda z: (
            -float(cast(float | int, z["composite"])),
            -float(cast(float | int, z["operational_risk_score"])),
            cast(str, z["resource"]),
        ),
    )[:25]

    mean_top = round(
        math.fsum(cast(float | int, r["composite"]) for r in top_crit[: min(12, len(top_crit))])
        / max(1, min(12, len(top_crit))),
        2,
    )

    exec_sum = {
        "vertices": len(verts),
        "edges_unique": len(g.edges),
        "starter_resource_count": len(starter_order),
        "prioritized_large_cycles": ac.prioritized_large_cycles,
        "fan_in_gate_top_5pct": percentile_high_floor(in_vals or [0], 0.05),
        "spof_candidate_count": len(ac.spof_candidates),
        "largest_scc_size": max((int(cast(int, r["size"])) for r in ac.scc_records), default=0),
        "scc_components_count": len(ac.scc_records),
        "undeclared_rows": ud_n,
        "composite_mean_top12": mean_top,
    }

    now = datetime.now(timezone.utc)
    md_ts = now.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    current_snapshot_basename = f"architecture-risk-{now.strftime('%Y%m%d-%H%M%S')}.json"

    spof_slice = ac.spof_candidates[:60]
    scc_slice = ac.scc_records[:40]
    trend_input: dict[str, Any] = {
        "executive_summary": exec_sum,
        "spof_candidates": spof_slice,
        "strongly_connected_components": scc_slice,
        "top_critical_resources": top_crit,
    }

    trend_analysis = build_trend_analysis(trend_input, previous_snapshot)
    risk_heatmap = build_risk_heatmap(ac, g)
    architectural_smells = build_architectural_smells(ac, payload, g, exec_sum)
    ownership_suggestions = build_ownership_suggestions(g.vertices)
    refactoring_roadmap = build_refactoring_roadmap(rem)
    coupling_analysis = build_coupling_analysis(ac, g.vertices)
    comparison_available_flag = previous_snapshot is not None
    blast_cmp_ok = regression_blast_cascade_comparison_enabled(previous_snapshot)
    regression_analysis = build_architectural_regression_detection(
        previous_snapshot,
        ac.resource_metrics,
        cast(list[str], trend_analysis["new_spofs"]),
        cast(list[str], trend_analysis["new_cycles"]),
        comparison_available_flag,
        blast_cmp_ok,
    )
    executive_scorecard = build_executive_scorecard(
        mean_top,
        regression_analysis,
        architectural_smells,
        exec_sum,
        ac,
        top_crit,
    )

    prev_gen = None
    if previous_snapshot:
        pm = previous_snapshot.get("metadata")
        if isinstance(pm, dict):
            prev_gen = pm.get("generated_at")

    historical_baseline = {
        "history_directory": str(Path("generated") / "history"),
        "retention_max_snapshots": HISTORY_MAX_FILES,
        "previous_snapshot_file": previous_snapshot_basename,
        "previous_generated_at": prev_gen,
        "current_snapshot_file": current_snapshot_basename,
        "comparison_available": previous_snapshot is not None,
    }

    return {
        "metadata": {
            "generated_at": md_ts,
            "source_dependency_graph_generated_at": str(payload.get("generated_at") or ""),
            "analyzer_version": ANALYZER_VERSION,
        },
        "executive_summary": exec_sum,
        "resource_metrics": {k: ac.resource_metrics[k] for k in sorted(ac.resource_metrics.keys())},
        "top_critical_resources": top_crit,
        "spof_candidates": spof_slice,
        "strongly_connected_components": scc_slice,
        "hidden_dependencies": ac.hidden_dependencies,
        "blast_radius": ac.blast_radius,
        "hardening_targets": harden,
        "refactoring_candidates": refactor,
        "remediation_backlog": rem,
        "trend_analysis": trend_analysis,
        "risk_heatmap": risk_heatmap,
        "architectural_smells": architectural_smells,
        "ownership_suggestions": ownership_suggestions,
        "refactoring_roadmap": refactoring_roadmap,
        "coupling_analysis": coupling_analysis,
        "regression_analysis": regression_analysis,
        "executive_scorecard": executive_scorecard,
        "historical_baseline": historical_baseline,
    }


def escape_md(cell: Any) -> str:
    return str(cell).replace("|", "\\|")


def render_markdown(doc: Mapping[str, Any]) -> str:
    meta = cast(dict[str, Any], doc["metadata"])
    es = cast(dict[str, Any], doc["executive_summary"])
    lines: list[str] = [
        "# Architecture risk intelligence — Vale do Ipiranga (MTA:SA)",
        "",
        f"Generated: `{meta.get('generated_at')}` · Source graph: `{meta.get('source_dependency_graph_generated_at')}` · Analyser: `{meta.get('analyzer_version')}`",
        "",
        "## Executive Summary",
        "",
        "| Métrica | Valor |",
        "|---------|------:|",
        f"| Vértices | {es.get('vertices')} |",
        f"| Arestas (exports ∪ refs ∪ meta) | {es.get('edges_unique')} |",
        f"| Recursos no starter_order | {es.get('starter_resource_count')} |",
        f"| SCCs prioritários (≥{SCC_MIN_SIZE_PRIO}, ρ≥{SCC_MIN_DENSITY_PRIO}) | {es.get('prioritized_large_cycles')} |",
        f"| Gate fan-in topo ~5 % | {es.get('fan_in_gate_top_5pct')} |",
        f"| Candidatos SPOF | {es.get('spof_candidate_count')} |",
        f"| Maior SCC | {es.get('largest_scc_size')} |",
        f"| Nº SCCs | {es.get('scc_components_count')} |",
        f"| Linhas undeclared_dependencies | {es.get('undeclared_rows')} |",
        f"| Média composite (top‑12) | {es.get('composite_mean_top12')} |",
        "",
        "**Composite:** `0.42·stability_score + 0.33·change_risk_score + 0.25·operational_risk_score` (min-max 0–100 por métrica, depois combinado).",
        "",
        "**Tiers composite:** LOW <26 · MODERATE <51 · HIGH <76 · CRITICAL ≥76.",
        "",
        "## Top Critical Resources",
        "",
        "| Rank | Resource | Composite | stability | change | operational | Tier | Class |",
        "|-----:|---------|----------:|----------:|-----:|-------------:|------|-------|",
    ]

    for i, row in enumerate(cast(list[Any], doc.get("top_critical_resources") or []), start=1):
        lines.append(
            "| {i} | {r} | {c:.2f} | {ss} | {cs} | {os} | {t} | {cl} |".format(
                i=i,
                r=escape_md(row["resource"]),
                c=float(cast(float | int, row["composite"])),
                ss=row["stability_score"],
                cs=row["change_risk_score"],
                os=row["operational_risk_score"],
                t=row["tier"],
                cl=escape_md(row["classification"]),
            )
        )

    lines += ["", "## Single Points of Failure", ""]
    for sp in cast(list[Any], doc.get("spof_candidates") or [])[:24]:
        rs = ", ".join(f"`{x}`" for x in cast(list[str], sp["reasons"]))
        lines.append(
            f"- **{sp['resource']}** — {rs} — in={sp['in_degree']} starter_direct={sp['direct_dependents_in_starter']}"
        )

    lines += ["", "## Strongly Connected Components", ""]
    for scc in cast(list[Any], doc.get("strongly_connected_components") or [])[:18]:
        tag = "**PRIORITIZED**" if scc.get("prioritized_dense_cycle") else ""
        mem = ", ".join(f"`{m}`" for m in cast(list[str], scc["members"])[:24])
        extra = " …" if len(cast(list[str], scc["members"])) > 24 else ""
        lines.append(
            f"- n={scc['size']} ρ={scc['directed_density']} internal={scc['internal_edges']} crit={scc['criticality_score']} {tag}"
        )
        lines.append(f"  - Membros: {mem}{extra}")
        lines.append("")

    lines += ["## Hidden Dependencies", ""]
    hd = cast(dict[str, Any], doc.get("hidden_dependencies") or {})
    lines.append("### ranked_undeclared_consumers (top)")
    for item in cast(list[Any], hd.get("ranked_undeclared_consumers") or [])[:12]:
        lines.append(f"- `{item['resource']}` aggregate={item['occurrence_aggregate']}")
    lines += ["", "### startup_hazard_samples", ""]
    for h in cast(list[Any], hd.get("startup_hazard_samples") or [])[:14]:
        lines.append(
            f"- `{h.get('consumer')}→{h.get('provider')}` count={h.get('occurrence_count')} kind=`{h.get('kind')}`"
        )

    lines += ["", "## Blast Radius Analysis", "", "| Rank | Resource | cascade | direct_starter | transitive_starter |", "|-----:|---------|---------:|---------------:|-------------------:|"]
    for i, b in enumerate(cast(list[Any], doc.get("blast_radius") or []), start=1):
        lines.append(
            f"| {i} | `{b['resource']}` | {b['cascade_score']} | {b['direct_dependents_in_starter']} | {b['transitive_dependents_in_starter']} |"
        )

    lines += ["", "## Hardening Targets", ""]
    for ht in cast(list[Any], doc.get("hardening_targets") or [])[:20]:
        lines.append(
            f"- **{ht['prioridade']}** `{ht['recurso']}` — _{escape_md(ht['razão'])[:180]}…_"
        )

    lines += ["", "## Refactoring Candidates", ""]
    for rf in cast(list[Any], doc.get("refactoring_candidates") or [])[:24]:
        lines.append(f"- **{escape_md(rf['recurso'])}** ({rf['tipo']}): {escape_md(rf['razão'])[:220]}")

    ta = cast(dict[str, Any], doc.get("trend_analysis") or {})
    lines += ["", "## Risk Trend Analysis", ""]
    sd = ta.get("score_delta")
    lines.append(f"- **risk_trend:** `{escape_md(ta.get('risk_trend'))}`")
    lines.append(f"- **score_delta (composite top‑12, actual − anterior):** `{escape_md(sd if sd is not None else 'n/a')}`")
    ns = ta.get("new_spofs") or []
    rs = ta.get("resolved_spofs") or []
    nc = ta.get("new_cycles") or []
    rc = ta.get("resolved_cycles") or []
    sp_ns = ", ".join(f"`{escape_md(x)}`" for x in cast(list[str], ns)[:24])
    lines.append(f"- **Novos candidatos SPOF:** {len(cast(list[Any], ns))} — {sp_ns if sp_ns else '—'}")
    lines.append(f"- **SPOF resolvidos (saíram da lista):** {len(cast(list[Any], rs))}")
    lines.append(f"- **Novas assinaturas de ciclos prioritários:** {len(cast(list[Any], nc))}")
    lines.append(f"- **Ciclos prioritários resolvidos:** {len(cast(list[Any], rc))}")
    lines.append(
        "_Regra: Δ ≤ −5 → IMPROVING; |Δ| < 5 → STABLE; Δ ≥ 5 → DEGRADING (média composite top‑12)._"
    )

    coup = cast(dict[str, Any], doc.get("coupling_analysis") or {})
    lines += ["", "## Coupling Analysis", ""]
    lines.append(
        "_afferent_coupling (**C<sub>a</sub>**): fan‑in efectivo (= `in_degree`); "
        "**efferent_coupling** (**C<sub>e</sub>**): fan‑out (= `out_degree`). "
        "`instability = C_e/(C_a+C_e)` quando C_a+C_e>0; métricas completas também em cada `resource_metrics`._"
    )
    lines.append("")
    lines.append("| Top mais instáveis | C_a | C_e | I | zona | cascade | composite |")
    lines.append("|----------|-----:|-----:|-------:|---------------|---------------:|---------------:|")
    for row in cast(list[Any], coup.get("top_most_unstable") or [])[:20]:
        if not isinstance(row, dict):
            continue
        lines.append(
            "| `{r}` | {ca} | {ce} | {i} | {z} | {c} | {co} |".format(
                r=escape_md(row.get("resource")),
                ca=int(row["afferent_coupling"]),
                ce=int(row["efferent_coupling"]),
                i=row["instability"],
                z=escape_md(row.get("coupling_zone")),
                c=row.get("cascade_score"),
                co=float(cast(float | int, row.get("composite", 0))),
            )
        )
    lines.append("")
    lines.append("| Top mais rígidos | C_a | C_e | I | zona | cascade | composite |")
    lines.append("|----------|-----:|-----:|-------:|---------------|---------------:|---------------:|")
    for row in cast(list[Any], coup.get("top_most_rigid") or [])[:20]:
        if not isinstance(row, dict):
            continue
        lines.append(
            "| `{r}` | {ca} | {ce} | {i} | {z} | {c} | {co} |".format(
                r=escape_md(row.get("resource")),
                ca=int(row["afferent_coupling"]),
                ce=int(row["efferent_coupling"]),
                i=row["instability"],
                z=escape_md(row.get("coupling_zone")),
                c=row.get("cascade_score"),
                co=float(cast(float | int, row.get("composite", 0))),
            )
        )
    lines.append("")
    lines.append("| Top mais acoplados | C_a | C_e | I | zona | cascade | composite |")
    lines.append("|----------|-----:|-----:|-------:|---------------|---------------:|---------------:|")
    for row in cast(list[Any], coup.get("top_most_coupled") or [])[:20]:
        if not isinstance(row, dict):
            continue
        lines.append(
            "| `{r}` | {ca} | {ce} | {i} | {z} | {c} | {co} |".format(
                r=escape_md(row.get("resource")),
                ca=int(row["afferent_coupling"]),
                ce=int(row["efferent_coupling"]),
                i=row["instability"],
                z=escape_md(row.get("coupling_zone")),
                c=row.get("cascade_score"),
                co=float(cast(float | int, row.get("composite", 0))),
            )
        )

    rex = cast(dict[str, Any], doc.get("regression_analysis") or {})
    lines += ["", "## Architectural Regression Detection", ""]
    lines.append(
        f"- **comparison_available:** `{rex.get('comparison_available')}` · **blast cascade compare:** `{rex.get('blast_cascade_comparison_enabled')}` · "
        f"**severity:** `{escape_md(rex.get('regression_severity'))}` · **regression_score (0–100):** `{rex.get('regression_score')}` · "
        f"**raw_penalty_units:** `{rex.get('raw_penalty_units')}`"
    )
    lines.append(
        "_Peso bruto típ.: novo SPOF +20; novo ciclo denso prioritário +30; blast radius regressivo +10 (\\>×1.2 cascata OU surgimento forte vs ~0 anterior); instability +\\>0.15 +10._"
    )
    lines.append("")
    for ev in cast(list[Any], rex.get("regression_events") or [])[:60]:
        if not isinstance(ev, dict):
            continue
        detail = escape_md(ev.get("delta_detail"))
        lines.append(
            f"- **`{escape_md(ev.get('type'))}`** `{escape_md(ev.get('resource'))}` — {detail[:180]}"
        )

    ecs = cast(dict[str, Any], doc.get("executive_scorecard") or {})
    lines += ["", "## Executive Scorecard", ""]
    lines.append("| KPI | Classificação / Score |")
    lines.append("|-----|-----------------------|")
    lines.append(f"| Architecture health score (0–100) | **{ecs.get('architecture_health_score')}** |")
    lines.append(f"| Risk maturity level | **{ecs.get('risk_maturity_level')}** |")
    lines.append(f"| Operational resilience | **{ecs.get('operational_resilience')}** |")
    lines.append(f"| Change safety | **{ecs.get('change_safety')}** |")
    lines.append(f"| Technical debt pressure | **{ecs.get('technical_debt_pressure')}** |")
    lines.append(
        "_Health: clamp(100 − composite_mean_top12×0.40 − regression_score×0.30 − critical_smells×4, 0, 100)._"
    )

    lines += ["", "## Architectural Smells", ""]
    for sm in cast(list[Any], doc.get("architectural_smells") or [])[:48]:
        if not isinstance(sm, dict):
            continue
        lines.append(
            f"- **[{escape_md(sm.get('severity'))}] {escape_md(sm.get('type'))}** — `{escape_md(sm.get('resource'))}` — {escape_md(sm.get('rationale'))[:200]}"
        )
        lines.append(f"  - *Recomendação:* {escape_md(sm.get('recommendation'))[:260]}")

    lines += ["", "## Ownership Recommendations", ""]
    ow_conf_rank = {"HIGH": 3, "MEDIUM": 2, "LOW": 1}
    own_rows = [x for x in cast(list[Any], doc.get("ownership_suggestions") or []) if isinstance(x, dict)]
    top_own = sorted(
        own_rows,
        key=lambda r: (
            -ow_conf_rank.get(cast(str, cast(dict[str, Any], r).get("ownership_confidence")), 0),
            cast(str, r.get("resource")),
        ),
    )[:48]
    for ow in top_own:
        if not isinstance(ow, dict):
            continue
        lines.append(
            f"- `{escape_md(ow.get('resource'))}` → equipa **{escape_md(ow.get('suggested_team'))}** (domínio `{escape_md(ow.get('domain'))}`, confiança **{escape_md(ow.get('ownership_confidence'))}**)"
        )

    hm = cast(dict[str, Any], doc.get("risk_heatmap") or {})
    lines += ["", "## Risk Heatmap", ""]
    lines.append(
        f"Medianas: cascade **{hm.get('blast_median_threshold')}** · total_degree **{hm.get('coupling_median_threshold_total_degree')}** "
        "(HIGH = ≥ mediana)."
    )
    qu = cast(dict[str, Any], hm.get("quadrants") or {})
    order_k = (
        "high_blast_high_coupling",
        "high_blast_low_coupling",
        "low_blast_high_coupling",
        "low_blast_low_coupling",
    )
    for qk in order_k:
        block = cast(dict[str, Any], qu.get(qk) or {})
        title = escape_md(block.get("title"))
        lines.append(f"### {title}")
        lines.append("| Rank | Resource | composite | cascade | degree |")
        lines.append("|-----:|---------|----------:|--------:|-------:|")
        for i, row in enumerate(cast(list[Any], block.get("top_10") or []), start=1):
            if not isinstance(row, dict):
                continue
            lines.append(
                f"| {i} | `{escape_md(row.get('resource'))}` | {row.get('composite')} | {row.get('cascade_score')} | {row.get('total_degree')} |"
            )
        lines.append("")

    lines += ["", "## Strategic Refactoring Roadmap", ""]
    rmap = cast(dict[str, Any], doc.get("refactoring_roadmap") or {})
    hlbl = cast(dict[str, Any], rmap.get("horizon_labels") or {})
    for hk, label in (
        ("immediate_7d", cast(str, hlbl.get("immediate_7d", "Immediate (7 dias)"))),
        ("near_term_30d", cast(str, hlbl.get("near_term_30d", "Near Term (30 dias)"))),
        ("strategic_90d", cast(str, hlbl.get("strategic_90d", "Strategic (90 dias)"))),
    ):
        lines.append(f"### {escape_md(label)}")
        for it in cast(list[Any], rmap.get(hk) or []):
            if not isinstance(it, dict):
                continue
            lines.append(
                f"- **{escape_md(it.get('title'))}** — alvo `{escape_md(it.get('target_resource'))}` · esforço *{escape_md(it.get('estimated_effort'))}* · redução esperada **{escape_md(it.get('expected_risk_reduction'))}**"
            )
            lines.append(f"  - {escape_md(it.get('rationale'))[:240]}")
        lines.append("")

    hb = cast(dict[str, Any], doc.get("historical_baseline") or {})
    lines += [
        "",
        "### Historical baseline",
        "",
        f"- Snapshot corrente (histórico): `{escape_md(hb.get('current_snapshot_file'))}`",
        f"- Snapshot anterior: `{escape_md(hb.get('previous_snapshot_file') if hb.get('previous_snapshot_file') else '—')}`",
        f"- Retenção: últimos **{hb.get('retention_max_snapshots')}** ficheiros em `{escape_md(hb.get('history_directory'))}`",
        "",
    ]

    lines += [
        "",
        "## Prioritized Remediation Backlog",
        "",
        "| prioridade | recurso | tipo | razão | acao | impacto | constrangimentos |",
        "|-----------|---------|------|-------|-----|---------|------------------|",
    ]
    for row in cast(list[Any], doc.get("remediation_backlog") or []):
        lines.append(
            "| {prio} | {rec} | {tipo} | {rz} | {ac} | {im} | {co} |".format(
                prio=escape_md(row["prioridade"]),
                rec=escape_md(row["recurso"]),
                tipo=escape_md(row["tipo"]),
                rz=escape_md(row["razão"]),
                ac=escape_md(row["acao"]),
                im=escape_md(row["impacto"]),
                co=escape_md(row["constrangimentos"]),
            )
        )

    lines += [
        "",
        "## Remediation Backlog",
        "",
        "_Mesmo conjunto que a tabela anterior (ordenado por criticidade)._",
        "",
    ]
    for row in cast(list[Any], doc.get("remediation_backlog") or []):
        lines.append(
            f"- **[{row['prioridade']}]** `{escape_md(row['recurso'])}` ({escape_md(row['tipo'])}): {escape_md(row['razão'])}"
        )

    lines += ["", "---", "_JSON canónico: `docs/generated/architecture-risk-report.json`_", ""]
    return "\n".join(lines)


def main() -> None:
    ap = argparse.ArgumentParser(description="Análise de risco arquitetural a partir do grafo de dependências.")
    ap.add_argument("--write", action="store_true", help="defaults: ler generated/resource-dependency-graph.json")
    ap.add_argument("--input", type=Path, metavar="PATH", help="ficheiro resource-dependency-graph.json")
    ap.add_argument("--json-output", dest="json_out", type=Path, metavar="PATH")
    ap.add_argument("--md-output", dest="md_out", type=Path, metavar="PATH")
    ns = ap.parse_args()

    in_path = ns.input or DEFAULT_GRAPH_PATH
    j_path = ns.json_out or DEFAULT_JSON_OUT_PATH
    m_path = ns.md_out or DEFAULT_MD_OUT_PATH
    if ns.write:
        in_path = DEFAULT_GRAPH_PATH
        j_path = DEFAULT_JSON_OUT_PATH
        m_path = DEFAULT_MD_OUT_PATH

    try:
        raw = load_dependency_graph_strict(in_path)
    except (FileNotFoundError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)

    graph = build_union_graph(raw)
    if not graph.vertices:
        print("Erro: grafo vazio (sem vértices).", file=sys.stderr)
        sys.exit(2)

    acore = run_analysis(raw, graph)
    prev_doc, prev_basename = load_newest_history_snapshot()
    report_doc = assemble_report(
        raw,
        graph,
        acore,
        previous_snapshot=prev_doc,
        previous_snapshot_basename=prev_basename,
    )
    json_payload = json.dumps(report_doc, indent=2, ensure_ascii=False) + "\n"
    atomic_write_text(j_path, json_payload)
    hist_base = cast(dict[str, Any], report_doc.get("historical_baseline") or {})
    snap_name = cast(str, hist_base.get("current_snapshot_file") or "")
    if snap_name:
        atomic_write_text(HISTORY_DIR / snap_name, json_payload)
        prune_history_snapshots_retention()
    atomic_write_text(m_path, render_markdown(report_doc))


if __name__ == "__main__":
    main()
