#!/usr/bin/env python3
"""MTA:SA gamemode resource dependency scanner (stdlib only, Python 3.10+).

Discovers export consumption, getResourceFromName / call(...) patterns, events,
cross-references oStarter ordering, emits JSON + Markdown report.

Usage:
  python3 docs/tooling/resource_dependency_scan.py [--root PATH] [--write]

Default root: parent folder of docs/ inside the vale-do-ipiranga gamemode tree.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable


SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_GAMEROOT = SCRIPT_DIR.parent.parent
STARTER_REL = Path("[Core]/oStarter/server.lua")

IGNORE_DIR_NAMES = frozenset(
    {
        ".git",
        ".cursor",
        ".claude",
        ".svn",
        "__pycache__",
        ".mypy_cache",
        ".pytest_cache",
        "node_modules",
        ".idea",
        ".vscode",
        "venv",
        ".venv",
        "cover",
        "htmlcov",
    }
)

# Framework resources to highlight (OriginalRP / Vale do Ipiranga)
CRITICAL_FRAMEWORK = frozenset(
    {
        "oMysql",
        "oCore",
        "oAccount",
        "oAdmin",
        "oStarter",
        "oInventory",
        "oVehicle",
        "vila-do-ipiranga-rp",
    }
)

_RE_EXPORT_DOT = re.compile(
    r"exports\s*\.\s*([a-zA-Z0-9_\-]+)\s*:\s*([a-zA-Z0-9_]+)",
    re.IGNORECASE,
)
_RE_EXPORT_BRACKET = re.compile(
    r'exports\s*\[\s*["\']([^"\']+)["\']\s*\]\s*:\s*([a-zA-Z0-9_]+)',
    re.IGNORECASE,
)
_RE_CALL_GRFN = re.compile(
    r'call\s*\(\s*getResourceFromName\s*\(\s*["\']([^"\']+)["\']\s*\)\s*,\s*["\']([^"\']+)["\']',
    re.IGNORECASE,
)
_RE_GRFN = re.compile(
    r'getResourceFromName\s*\(\s*["\']([^"\']+)["\']\s*\)',
    re.IGNORECASE,
)
_RE_TRIGGER_SERVER = re.compile(
    r"triggerServerEvent\s*\(\s*[\"']([^\"']+)[\"']",
    re.IGNORECASE,
)
_RE_TRIGGER_CLIENT = re.compile(
    r"triggerClientEvent\s*\(\s*[\"']([^\"']+)[\"']",
    re.IGNORECASE,
)
_RE_TRIGGER_LATENT = re.compile(
    r"triggerLatentClientEvent\s*\(\s*[\"']([^\"']+)[\"']",
    re.IGNORECASE,
)
# triggerEvent(element, "name", …) single-line heuristic
_RE_TRIGGER_EVENT_INLINE = re.compile(
    r"triggerEvent\s*\([^,\)]*,\s*[\"']([^\"']+)[\"']",
    re.IGNORECASE,
)
_RE_ADD_EVENT = re.compile(
    r"addEvent\s*\(\s*[\"']([^\"']+)[\"']",
    re.IGNORECASE,
)
_RE_ADD_HANDLER = re.compile(
    r"addEventHandler\s*\(\s*[\"']([^\"']+)[\"']",
    re.IGNORECASE,
)
_RE_META_INCLUDE = re.compile(
    r'<include\b[^>]*\bresource\s*=\s*["\']([^"\']+)["\']',
    re.IGNORECASE,
)
_RE_EXPORT_META = re.compile(
    r'<export\b[^>]*\bfunction\s*=\s*["\']([^"\']+)["\']',
    re.IGNORECASE,
)
_RE_STARTER_INSERT = re.compile(
    r'^\s*table\.insert\s*\(\s*resources\s*,\s*["\']([^"\']+)["\']\s*\)',
)


def strip_lua_tail_comment(s: str) -> str:
    """Remove `--` trailing comment heuristic (quotes balanced)."""
    in_q: str | None = None
    i = 0
    n = len(s)
    while i < n - 1:
        ch = s[i]
        if in_q:
            if ch == in_q and (i == 0 or s[i - 1] != "\\"):
                in_q = None
            i += 1
            continue
        if ch in "'\"":
            in_q = ch
            i += 1
            continue
        if ch == "-" and s[i + 1] == "-":
            return s[:i].rstrip()
        i += 1
    return s


def should_skip_path(path: Path) -> bool:
    parts = set(path.parts)
    return bool(parts & IGNORE_DIR_NAMES)


def discover_resources(root: Path) -> dict[str, Path]:
    """Resource name -> absolute path to resource directory (contains meta.xml)."""
    out: dict[str, Path] = {}
    root = root.resolve()
    if not root.is_dir():
        return out
    for dirpath, dirnames, filenames in os.walk(root, topdown=True):
        dpath = Path(dirpath)
        if should_skip_path(dpath):
            dirnames[:] = []
            continue
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIR_NAMES and not d.startswith(".")]
        if "meta.xml" in filenames:
            name = dpath.name
            # Last wins on duplicate names (should not happen in sane trees)
            out[name] = dpath
    return out


def parse_starter_list(gameroot: Path) -> list[str]:
    starter_path = gameroot / STARTER_REL
    if not starter_path.is_file():
        return []
    order: list[str] = []
    seen: set[str] = set()
    try:
        text = starter_path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return []
    for line in text.splitlines():
        ls = line.lstrip()
        if ls.startswith("--"):
            continue
        m = _RE_STARTER_INSERT.match(line)
        if m:
            name = m.group(1)
            if name not in seen:
                seen.add(name)
                order.append(name)
    return order


def fk_skin_resources(resource_names: Iterable[str]) -> list[str]:
    return sorted(n for n in resource_names if n.startswith("oFKSkins_"))


def effective_starter_order(
    base_order: list[str], resource_names: set[str]
) -> list[str]:
    """Append oFKSkins_* present on disk (mirrors oStarter loop behaviour)."""
    order = list(base_order)
    seen = set(order)
    for fk in fk_skin_resources(resource_names):
        if fk not in seen:
            order.append(fk)
            seen.add(fk)
    return order


def rel_path(file_path: Path, root: Path) -> str:
    try:
        return str(file_path.resolve().relative_to(root.resolve()))
    except ValueError:
        return str(file_path)


def scan_lua_file(
    file_path: Path,
    consumer: str,
    scan_root: Path,
) -> dict[str, list[dict[str, Any]]]:
    """Return buckets of findings for one file."""
    buckets: dict[str, list[dict[str, Any]]] = {
        "export_uses": [],
        "call_grfn": [],
        "grfn_refs": [],
        "trigger_server": [],
        "trigger_client": [],
        "trigger_latent": [],
        "trigger_event": [],
        "add_event": [],
        "add_handler": [],
    }
    try:
        lines = file_path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except OSError:
        return buckets

    rel = rel_path(file_path, scan_root)
    for lineno, line in enumerate(lines, start=1):
        if re.match(r"^\s*--", line):
            continue
        line = strip_lua_tail_comment(line)

        # exports.resource:fn
        for m in _RE_EXPORT_DOT.finditer(line):
            buckets["export_uses"].append(
                {
                    "consumer": consumer,
                    "provider": m.group(1),
                    "function": m.group(2),
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_EXPORT_BRACKET.finditer(line):
            buckets["export_uses"].append(
                {
                    "consumer": consumer,
                    "provider": m.group(1),
                    "function": m.group(2),
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_CALL_GRFN.finditer(line):
            buckets["call_grfn"].append(
                {
                    "consumer": consumer,
                    "provider": m.group(1),
                    "function": m.group(2),
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_GRFN.finditer(line):
            name = m.group(1)
            # Skip if already captured as part of call() on same line (dedupe loose)
            buckets["grfn_refs"].append(
                {
                    "from_resource": consumer,
                    "target_resource": name,
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_TRIGGER_SERVER.finditer(line):
            buckets["trigger_server"].append(
                {
                    "resource": consumer,
                    "event": m.group(1),
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_TRIGGER_CLIENT.finditer(line):
            buckets["trigger_client"].append(
                {
                    "resource": consumer,
                    "event": m.group(1),
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_TRIGGER_LATENT.finditer(line):
            buckets["trigger_latent"].append(
                {
                    "resource": consumer,
                    "event": m.group(1),
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_TRIGGER_EVENT_INLINE.finditer(line):
            buckets["trigger_event"].append(
                {
                    "resource": consumer,
                    "event": m.group(1),
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_ADD_EVENT.finditer(line):
            buckets["add_event"].append(
                {
                    "resource": consumer,
                    "event": m.group(1),
                    "file": rel,
                    "line": lineno,
                }
            )
        for m in _RE_ADD_HANDLER.finditer(line):
            buckets["add_handler"].append(
                {
                    "resource": consumer,
                    "event": m.group(1),
                    "file": rel,
                    "line": lineno,
                }
            )
    return buckets


def parse_meta_dependencies(res_dir: Path, res_name: str, scan_root: Path) -> dict[str, Any]:
    meta = res_dir / "meta.xml"
    out: dict[str, Any] = {
        "includes": [],
        "exports_declared": [],
    }
    if not meta.is_file():
        return out
    try:
        raw = meta.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return out
    out["includes"] = _RE_META_INCLUDE.findall(raw)
    out["exports_declared"] = _RE_EXPORT_META.findall(raw)
    return out


def build_event_edges(
    all_handlers: list[dict[str, Any]],
    all_triggers: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    """Heuristic: match event name string across resources (high false-positive rate)."""
    handlers_by_event: dict[str, list[str]] = defaultdict(list)
    for h in all_handlers:
        handlers_by_event[h["event"]].append(h["resource"])
    edges: list[dict[str, Any]] = []
    seen: set[tuple[str, str, str]] = set()
    for t in all_triggers:
        ev = t["event"]
        emitters = t["resource"]
        for target in handlers_by_event.get(ev, []):
            if target == emitters:
                continue
            key = (emitters, target, ev)
            if key in seen:
                continue
            seen.add(key)
            edges.append(
                {
                    "event": ev,
                    "emitter_resource": emitters,
                    "listener_resource": target,
                    "heuristic": True,
                    "note": "Matched by event name only; same string may denote unrelated events.",
                }
            )
    return edges


def dedupe_reference_rows(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    seen: set[tuple[Any, ...]] = set()
    out: list[dict[str, Any]] = []
    for r in rows:
        key = (
            r.get("from_resource"),
            r.get("target_resource"),
            r.get("file"),
            r.get("line"),
        )
        if key in seen:
            continue
        seen.add(key)
        out.append(r)
    return out


def dedupe_export_rows(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    seen: set[tuple[Any, ...]] = set()
    out: list[dict[str, Any]] = []
    for r in rows:
        key = (
            r.get("consumer"),
            r.get("provider"),
            r.get("function"),
            r.get("file"),
            r.get("line"),
            r.get("via"),
        )
        if key in seen:
            continue
        seen.add(key)
        out.append(r)
    return out


def mutual_export_pairs(edges: list[tuple[str, str]]) -> list[dict[str, str]]:
    eset = set(edges)
    out: list[dict[str, str]] = []
    seen: set[tuple[str, str]] = set()
    for a, b in eset:
        if a == b:
            continue
        if (b, a) in eset:
            u, v = sorted((a, b))
            t = (u, v)
            if t not in seen:
                seen.add(t)
                out.append({"resource_a": u, "resource_b": v})
    return sorted(out, key=lambda d: (d["resource_a"], d["resource_b"]))


def find_export_cycles(
    edges: list[tuple[str, str]],
) -> list[list[str]]:
    """Tarjan SCC on directed graph consumer->provider (export dependency)."""
    adj: dict[str, set[str]] = defaultdict(set)
    nodes: set[str] = set()
    for a, b in edges:
        if a == b:
            continue
        adj[a].add(b)
        nodes.add(a)
        nodes.add(b)
    index: dict[str, int] = {}
    lowlink: dict[str, int] = {}
    stack: list[str] = []
    onstack: set[str] = set()
    sccs: list[list[str]] = []
    idx = [0]

    def strongconnect(v: str) -> None:
        index[v] = idx[0]
        lowlink[v] = idx[0]
        idx[0] += 1
        stack.append(v)
        onstack.add(v)
        for w in adj.get(v, ()):
            if w not in index:
                strongconnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            elif w in onstack:
                lowlink[v] = min(lowlink[v], index[w])
        if lowlink[v] == index[v]:
            comp: list[str] = []
            while True:
                w = stack.pop()
                onstack.discard(w)
                comp.append(w)
                if w == v:
                    break
            if len(comp) > 1:
                sccs.append(sorted(comp))
            else:
                w0 = comp[0]
                if w0 in adj.get(w0, set()):
                    sccs.append(comp)

    for v in sorted(nodes):
        if v not in index:
            strongconnect(v)
    # Dedupe sorted tuples
    uniq: set[tuple[str, ...]] = set()
    out: list[list[str]] = []
    for comp in sccs:
        t = tuple(comp)
        if t not in uniq:
            uniq.add(t)
            out.append(comp)
    return out


def analyze_undeclared(
    export_rows: list[dict[str, Any]],
    starter_order: list[str],
    known_resources: set[str],
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    """Load-order violations + targets outside starter set / missing on disk."""
    pos = {name: i for i, name in enumerate(starter_order)}
    starter_set = set(starter_order)
    findings_raw: list[dict[str, Any]] = []

    def flag(
        kind: str,
        consumer: str,
        provider: str,
        fn: str | None,
        detail: str,
        file_: str | None = None,
        line: int | None = None,
    ) -> None:
        findings_raw.append(
            {
                "kind": kind,
                "consumer": consumer,
                "provider": provider,
                "function": fn,
                "detail": detail,
                "file": file_,
                "line": line,
                "critical_path": consumer in CRITICAL_FRAMEWORK
                or provider in CRITICAL_FRAMEWORK,
            }
        )

    for row in export_rows:
        consumer = row["consumer"]
        provider = row["provider"]
        fn = row.get("function")
        file_ = row.get("file")
        line = row.get("line")
        if provider not in known_resources:
            flag(
                "external_or_missing_resource",
                consumer,
                provider,
                fn,
                "Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic).",
                file_,
                line,
            )
            continue
        # Only Starter-scoped coupling analysis
        c_in = consumer in starter_set
        p_in = provider in starter_set
        if not c_in and not p_in:
            continue
        if consumer == "vila-do-ipiranga-rp" or provider == "vila-do-ipiranga-rp":
            pass

        if p_in and c_in:
            pi, ci = pos.get(provider, -1), pos.get(consumer, -1)
            if pi == -1 or ci == -1:
                flag(
                    "starter_index_missing",
                    consumer,
                    provider,
                    fn,
                    "Consumer or provider missing from parsed starter sequence.",
                    file_,
                    line,
                )
            elif pi >= ci:
                flag(
                    "fragile_load_order",
                    consumer,
                    provider,
                    fn,
                    f"Provider `{provider}` starts at same index or after `{consumer}` in oStarter (export may run before provider is ready during boot).",
                    file_,
                    line,
                )
        elif p_in and not c_in:
            flag(
                "non_starter_consumes_starter",
                consumer,
                provider,
                fn,
                "Consumer not in oStarter list but calls starter resource (optional/legacy resource coupling).",
                file_,
                line,
            )
        elif not p_in and c_in:
            flag(
                "starter_consumes_non_starter",
                consumer,
                provider,
                fn,
                "Starter resource depends on resource not present in oStarter order (may still be started elsewhere or internal name mismatch).",
                file_,
                line,
            )

    buckets: dict[tuple[Any, ...], dict[str, Any]] = {}
    for r in findings_raw:
        k = (r["kind"], r["consumer"], r["provider"])
        if k not in buckets:
            buckets[k] = {
                "kind": r["kind"],
                "consumer": r["consumer"],
                "provider": r["provider"],
                "occurrence_count": 0,
                "critical_path": r["critical_path"],
                "sample_files": [],
                "functions_sample": [],
                "detail": r["detail"],
            }
        b = buckets[k]
        b["occurrence_count"] += 1
        b["critical_path"] = b["critical_path"] or r["critical_path"]
        fp = r.get("file")
        if fp is not None and len(b["sample_files"]) < 5:
            b["sample_files"].append(
                {"file": fp, "line": r.get("line"), "function": r.get("function")}
            )
        fnn = r.get("function")
        if fnn and fnn not in b["functions_sample"] and len(b["functions_sample"]) < 12:
            b["functions_sample"].append(fnn)

    aggregated = sorted(
        buckets.values(),
        key=lambda x: (-x["occurrence_count"], str(x["kind"]), str(x["consumer"])),
    )

    return findings_raw, aggregated


def run_scan(scan_root: Path, gameroot: Path) -> dict[str, Any]:
    scan_root = scan_root.resolve()
    gameroot = gameroot.resolve()
    resources = discover_resources(scan_root)
    res_names = set(resources.keys())

    starter_base = parse_starter_list(gameroot)
    starter_order = effective_starter_order(starter_base, res_names)

    export_rows: list[dict[str, Any]] = []
    call_rows: list[dict[str, Any]] = []
    reference_rows: list[dict[str, Any]] = []
    triggers_all: list[dict[str, Any]] = []
    handlers_all: list[dict[str, Any]] = []
    add_events: list[dict[str, Any]] = []
    meta_includes: list[dict[str, Any]] = []

    resource_meta: dict[str, Any] = {}

    for rname, rpath in sorted(resources.items()):
        resource_meta[rname] = {
            "path": str(rpath.relative_to(scan_root)),
            **parse_meta_dependencies(rpath, rname, scan_root),
        }
        incs = resource_meta[rname]["includes"]
        for inc in incs:
            meta_includes.append(
                {
                    "resource": rname,
                    "includes": inc,
                    "declared_dependency": True,
                }
            )
        lua_count = 0
        for dirpath, dirnames, filenames in os.walk(rpath):
            dp = Path(dirpath)
            if should_skip_path(dp):
                dirnames[:] = []
                continue
            dirnames[:] = [d for d in dirnames if d not in IGNORE_DIR_NAMES]
            for fn in filenames:
                if not fn.endswith(".lua"):
                    continue
                fpath = dp / fn
                lua_count += 1
                buckets = scan_lua_file(fpath, rname, scan_root)
                export_rows.extend(buckets["export_uses"])
                for row in buckets["call_grfn"]:
                    call_rows.append(row)
                    export_rows.append(
                        {
                            "consumer": row["consumer"],
                            "provider": row["provider"],
                            "function": row["function"],
                            "file": row["file"],
                            "line": row["line"],
                            "via": "call(getResourceFromName,...)",
                        }
                    )
                reference_rows.extend(buckets["grfn_refs"])
                for x in buckets["trigger_server"]:
                    triggers_all.append({**x, "kind": "triggerServerEvent"})
                for x in buckets["trigger_client"]:
                    triggers_all.append({**x, "kind": "triggerClientEvent"})
                for x in buckets["trigger_latent"]:
                    triggers_all.append({**x, "kind": "triggerLatentClientEvent"})
                for x in buckets["trigger_event"]:
                    triggers_all.append({**x, "kind": "triggerEvent"})
                for x in buckets["add_handler"]:
                    handlers_all.append({**x, "kind": "addEventHandler"})
                for x in buckets["add_event"]:
                    add_events.append({**x, "kind": "addEvent"})

        resource_meta[rname]["lua_files_scanned"] = lua_count

    export_rows = dedupe_export_rows(export_rows)

    # Validate export vs meta (undeclared export usage is normal; missing meta export is "dynamic")
    meta_export_map: dict[str, set[str]] = {
        n: set(resource_meta.get(n, {}).get("exports_declared", [])) for n in resource_meta
    }

    export_validation: list[dict[str, Any]] = []
    for row in export_rows:
        prov = row["provider"]
        fn = row["function"]
        if prov in meta_export_map and fn not in meta_export_map[prov]:
            export_validation.append(
                {
                    "consumer": row["consumer"],
                    "provider": prov,
                    "function": fn,
                    "note": "Function not listed in provider meta.xml <export> (may still exist at runtime or use legacy export pattern).",
                    "file": row.get("file"),
                    "line": row.get("line"),
                }
            )

    edge_pairs = [(r["consumer"], r["provider"]) for r in export_rows if r["consumer"] != r["provider"]]
    cycles = find_export_cycles(edge_pairs)
    largest_scc = max((len(c) for c in cycles), default=0)
    mutual = mutual_export_pairs(edge_pairs)

    undeclared_raw, undeclared_agg = analyze_undeclared(
        export_rows, starter_order, res_names
    )

    event_edges = build_event_edges(handlers_all, triggers_all)

    # Fan-in / fan-out (export graph, distinct providers per consumer / consumers per provider)
    fan_out: dict[str, set[str]] = defaultdict(set)
    fan_in: dict[str, set[str]] = defaultdict(set)
    for row in export_rows:
        c, p = row["consumer"], row["provider"]
        if c != p:
            fan_out[c].add(p)
            fan_in[p].add(c)

    top_consumers = sorted(fan_out.items(), key=lambda x: len(x[1]), reverse=True)[:25]
    top_providers = sorted(fan_in.items(), key=lambda x: len(x[1]), reverse=True)[:25]

    hidden_coupling = [
        r
        for r in reference_rows
        if r["from_resource"] != r["target_resource"]
        and r["target_resource"] in starter_order
    ]

    # Dedupe cross-resource heuristic events (emitter,listener,ev) explosive size
    _ev_seen: set[tuple[str, str, str]] = set()
    event_edges_slim: list[dict[str, Any]] = []
    for ed in event_edges:
        kk = (
            ed.get("emitter_resource", ""),
            ed.get("listener_resource", ""),
            ed.get("event", ""),
        )
        if kk not in _ev_seen:
            _ev_seen.add(kk)
            event_edges_slim.append(ed)
    # Cap JSON/list size for readability in viewers (full deduped retained)
    event_edges_json = (
        event_edges_slim[:8000] if len(event_edges_slim) > 8000 else event_edges_slim
    )

    reference_rows = dedupe_reference_rows(reference_rows)

    return {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "scan_root": str(scan_root),
        "gameroot_for_starter": str(gameroot),
        "starter_order": starter_order,
        "starter_count": len(starter_order),
        "resources_discovered": len(resources),
        "resources": resource_meta,
        "exports": export_rows,
        "export_meta_mismatches_sample": export_validation[:500],
        "export_meta_mismatch_count": len(export_validation),
        "events": triggers_all + handlers_all + add_events,
        "event_inter_resource_heuristic": event_edges_json,
        "event_inter_resource_heuristic_deduped_total": len(event_edges_slim),
        "references": reference_rows,
        "call_getResourceFromName": call_rows,
        "meta_includes": meta_includes,
        "undeclared_dependencies": undeclared_agg,
        "undeclared_dependencies_raw_rows": len(undeclared_raw),
        "summary": {
            "export_use_count": len(export_rows),
            "unique_event_names_triggered": len({e["event"] for e in triggers_all}),
            "unique_event_names_handled": len({e["event"] for e in handlers_all}),
            "getResourceFromName_literal_count": len(reference_rows),
            "mutual_export_pairs": mutual,
            "mutual_export_pair_count": len(mutual),
            "largest_export_scc_size": largest_scc,
            "export_scc_count": len(cycles),
            "top_consumers_by_distinct_export_targets": [
                {"resource": k, "distinct_providers": len(v), "providers_sample": sorted(v)[:20]}
                for k, v in top_consumers
            ],
            "top_providers_by_distinct_consumers": [
                {"resource": k, "distinct_consumers": len(v), "consumers_sample": sorted(v)[:20]}
                for k, v in top_providers
            ],
            "hidden_coupling_grfn_count": len(hidden_coupling),
        },
    }


def write_markdown_report(data: dict[str, Any], path: Path) -> None:
    s = data["summary"]
    lines: list[str] = [
        "# Resource dependency report",
        "",
        f"**Generated (UTC):** `{data['generated_at']}`  ",
        f"**Scan root:** `{data['scan_root']}`  ",
        f"**Starter parsed from:** `{data['gameroot_for_starter']}/{STARTER_REL.as_posix()}`  ",
        "",
        "## Executive summary",
        "",
        "| Metric | Value |",
        "|--------|------:|",
        f"| Resources with `meta.xml` | {data['resources_discovered']} |",
        f"| Effective starter order length (incl. `oFKSkins_*` on disk) | {data['starter_count']} |",
        f"| `exports.*:*` / `call(...)` edges | {s['export_use_count']} |",
        f"| Literal `getResourceFromName(\"...\")` hits | {s['getResourceFromName_literal_count']} |",
        f"| Trigger/handler/addEvent records | {len(data['events'])} |",
        f"| Heuristic cross-resource event edges (JSON truncado ≥8k) | {len(data['event_inter_resource_heuristic'])} |",
        f"| Heuristic event edges deduped total | {data.get('event_inter_resource_heuristic_deduped_total', len(data['event_inter_resource_heuristic']))} |",
        f"| Undeclared / load-order **aggregated** flags | {len(data['undeclared_dependencies'])} |",
        f"| Undeclared raw edge rows (pre-aggregate) | {data.get('undeclared_dependencies_raw_rows', 0)} |",
        f"| Mutual export pairs (A↔B) | {s.get('mutual_export_pair_count', 0)} |",
        f"| Largest export SCC size | {s.get('largest_export_scc_size', 0)} | (#SCCs {s.get('export_scc_count', 0)})",
        "",
        "**Critical framework resources** (prioridade revisão): "
        + ", ".join(f"`{x}`" for x in sorted(CRITICAL_FRAMEWORK)),
        "",
        "### Limitações (ler antes de actuar)",
        "",
        "- Análise **linha a linha**; padrões multilinha ou nomes concatenados dinamicamente **não** aparecem.",
        "- Ramos `exports['x']:y` com `x` variável são ignorados.",
        "- Custos **`event`**: igualdade do **nome da string** entre `trigger*` e `addEventHandler` **não** prova mesmo canal nem contrato estável.",
        "- `undeclared_dependencies` cruzadas com **`oStarter`** apenas para raciocínio de boot; chamadas feitas minutos depois podem estar seguras mesmo com índices \"invertidos\".",
        "",
        "## Top dependency consumers (distinct `exports` targets)",
        "",
        "| Rank | Resource | # distinct providers |",
        "|-----:|----------|----------------------:|",
    ]

    for i, row in enumerate(s["top_consumers_by_distinct_export_targets"][:15], start=1):
        lines.append(
            f"| {i} | `{row['resource']}` | {row['distinct_providers']} |",
        )

    lines += [
        "",
        "## Top dependency providers (distinct consumers)",
        "",
        "| Rank | Resource | # distinct consumers |",
        "|-----:|----------|-----------------------:|",
    ]
    for i, row in enumerate(s["top_providers_by_distinct_consumers"][:15], start=1):
        lines.append(
            f"| {i} | `{row['resource']}` | {row['distinct_consumers']} |",
        )

    lines += [
        "",
        "## Mutual export dependencies (bidirectional `exports` graph)",
        "",
        "Pares onde **ambos** os recursos chamam um ao outro via `exports.X:Y` (candidatos a ciclos de inicialização reais mais acçãoáveis do que um SCC gigante).",
        "",
        "| # | Resource A | Resource B |",
        "|--:|------------|------------|",
    ]
    for i, mp in enumerate(s.get("mutual_export_pairs", [])[:40], start=1):
        lines.append(f"| {i} | `{mp['resource_a']}` | `{mp['resource_b']}` |")
    lscc = s.get("largest_export_scc_size", 0)
    lines.append("")
    lines.append(
        f"*Nota analítica:* o grafo dirigido completo pode ter uma SCC enorme (tamanho máximo **{lscc}**)."
        " Isso frequentemente reflecte um **hub** (ex.: `oCore`) mais do que um ciclo de refactor único."
        " Priorizar triagem pelos pares mútuos acima e por `fragile_load_order` no JSON.*"
    )

    lines += [
        "",
        "## High‑risk findings (starter / load order / missing folder)",
        "",
    ]
    crit = [
        x for x in data["undeclared_dependencies"] if x.get("critical_path") or x["kind"] in ("fragile_load_order", "external_or_missing_resource")
    ]
    crit_sorted = sorted(
        crit,
        key=lambda x: (x["kind"], x.get("consumer", ""), x.get("provider", "")),
    )
    lines.append("| kind | consumer | provider | #hits | functions (sample) | detail |")
    lines.append("|------|----------|----------|------:|---------------------|--------|")
    for row in crit_sorted[:80]:
        d = row["detail"].replace("|", "\\|")[:160]
        hits = row.get("occurrence_count", 1)
        fs = ", ".join(row.get("functions_sample") or [])[:120]
        lines.append(
            f"| `{row['kind']}` | `{row.get('consumer')}` | `{row.get('provider')}` | {hits} | `{fs}` | {d} |",
        )
    if len(crit_sorted) > 80:
        lines.append(f"*… {len(crit_sorted) - 80} linhas adicionais no JSON.*")

    lines += [
        "",
        "## Hidden coupling: `getResourceFromName(\"…\")` (sample)",
        "",
        "Útil para encontrar bypass explícito a `exports.` (acoplamento menos visível nos greps antigos).",
        "",
        "| from | target | file:line |",
        "|------|--------|-----------|",
    ]
    sample_refs = sorted(
        {(r["from_resource"], r["target_resource"], r["file"], r["line"]) for r in data["references"]},
        key=lambda t: (t[1], t[0], t[2], t[3] or 0),
    )[:40]
    for fr, tg, fp, ln in sample_refs[:40]:
        lines.append(f"| `{fr}` | `{tg}` | `{fp}:{ln}` |")

    lines += [
        "",
        "## `meta.xml` `<include resource=\"…\"/>` (declared)",
        "",
    ]
    if not data["meta_includes"]:
        lines.append("*Nenhum include encontrado neste scan (normal em muitos recursos ORP).*")
    else:
        lines.append("| resource | includes |")
        lines.append("|----------|----------|")
        for row in data["meta_includes"][:40]:
            lines.append(f"| `{row['resource']}` | `{row['includes']}` |")

    lines += [
        "",
        "## Export vs `meta.xml` mismatch (sample)",
        "",
        "Chamadas a funções **não** listadas no `meta.xml` do provider (primeiras 30). Muitas bases MTA ainda funcionam quando exports são implícitos ou meta desactualizada.",
        "",
        "| consumer | provider | function |",
        "|----------|----------|----------|",
    ]
    for row in data["export_meta_mismatches_sample"][:30]:
        lines.append(
            f"| `{row['consumer']}` | `{row['provider']}` | `{row['function']}` |",
        )

    lines += [
        "",
        "## Machine-readable output",
        "",
        "Ver [`resource-dependency-graph.json`](resource-dependency-graph.json) (mesmo scan).",
        "",
        "## Regenerar",
        "",
        "```bash",
        "cd mods/deathmatch/resources/vila-do-ipiranga-rp",
        "python3 docs/tooling/resource_dependency_scan.py --write",
        "```",
        "",
    ]

    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description="MTA resource dependency scan")
    ap.add_argument(
        "--root",
        type=Path,
        default=DEFAULT_GAMEROOT,
        help="Directory tree containing resource folders (default: vale gamemode root)",
    )
    ap.add_argument(
        "--gameroot",
        type=Path,
        default=None,
        help="Path containing [Core]/oStarter/server.lua (default: same as --root)",
    )
    ap.add_argument(
        "--write",
        action="store_true",
        help=f"Write {DEFAULT_GAMEROOT}/docs/generated/resource-dependency-graph.json and report.md",
    )
    args = ap.parse_args()
    scan_root: Path = args.root.resolve()
    gameroot = (args.gameroot or scan_root).resolve()

    data = run_scan(scan_root, gameroot)
    txt = json.dumps(data, indent=2, ensure_ascii=False)
    if args.write:
        gen = gameroot / "docs" / "generated"
        gen.mkdir(parents=True, exist_ok=True)
        jpath = gen / "resource-dependency-graph.json"
        mpath = gen / "resource-dependency-report.md"
        jpath.write_text(txt, encoding="utf-8")
        write_markdown_report(data, mpath)
        print(f"Wrote {jpath}", file=sys.stderr)
        print(f"Wrote {mpath}", file=sys.stderr)
    else:
        print(txt[:200000])
        if len(txt) > 200000:
            print("\n...[truncated stdout; use --write for full JSON]...", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
