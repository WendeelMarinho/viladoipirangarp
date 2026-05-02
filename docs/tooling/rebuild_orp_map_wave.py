#!/usr/bin/env python3
"""Reestrutura ORP_ORIGINAL_RP_START_ORDER: fase única de mapas cedo.

Após infra + Destroyer + Water + Mapfix + SampModels:
  coloca todos os recursos que declaram <map> no meta.xml (menos exclusions),
  em ordem lexical determinística.

Uso:
  cd mods/deathmatch/resources/vila-do-ipiranga-rp && python3 docs/tooling/rebuild_orp_map_wave.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1].parent  # pacote gamemode
MANI = ROOT / "[Core]/oStarter/starter_manifest.lua"

EXCLUDE_MAPS: frozenset[str] = frozenset(
    {
        "asd_deli",
        "asd_vh",
        "f1map2",
        "rallymap",
        "pizzahut2",
        "traincart-design-template",
        "map",  # colisão: sub-recurso em oTraffipax
        "oBahamaMapOLD",
        "oBankMap_OLD",
        "oCleanerMapOLD",
        "oFireDepartmentMap_OLD",
        "oFurnitureJobMap_OLD",
        "oGovernmentOLD",
        "oHospitalMapOLDOLD",
        "oHospitalOutsideMap_OLD",
        "oMechanicMap_OLD",
        "oPoliceInterior",
        "oPoliceMap",
        "oTaxiHQOLD",
        "oUjsagOLD",
        "oUjszerelo_OLD",
        "oVH_Map_OLD",
        "oPiruMap",
    }
)


def discover_map_resources(base: Path) -> set[str]:
    out: set[str] = set()
    for mx in base.rglob("meta.xml"):
        try:
            t = mx.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if not re.search(r"<map\b", t, re.I):
            continue
        nm = mx.parent.name
        if nm == "map":
            continue
        out.add(nm)
    return out


def extract_lua_string_array(marker: str, text: str) -> tuple[int, int, list[str]]:
    """Índices (início inclusivo, fecha `}` exclusivo) e strings do array `{ ... }`."""
    m_idx = text.index(marker)
    open_b = text.index("{", m_idx)
    depth = 0
    i = open_b
    while i < len(text):
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i  # índice do `}`
                chunk = text[open_b + 1 : end]
                items = re.findall(r'"([^"]*)"', chunk)
                inner_start = open_b + 1
                return inner_start, end, items
        i += 1
    raise ValueError(f"fecha-chavetas em falta após '{marker}'")


def main() -> int:
    if not MANI.is_file():
        print(f"não existe {MANI}", file=sys.stderr)
        return 2

    raw = MANI.read_text(encoding="utf-8")

    marker = "ORP_ORIGINAL_RP_START_ORDER"
    inner_start, end_brace, items = extract_lua_string_array(f"{marker} =", raw)

    order = ["oPiruMapOLD" if x == "oPiruMap" else x for x in items]

    try:
        ni = order.index("npc_hlc")
    except ValueError as exc:
        print("lista sem npc_hlc", exc, file=sys.stderr)
        return 3

    infra = order[: ni + 1]
    tail = order[ni + 1 :]
    infra_set = set(infra)

    has_map_meta = discover_map_resources(ROOT)
    eligible = sorted((has_map_meta - EXCLUDE_MAPS) | {"oPiruMapOLD"})

    world_prep = ("oDestroyer", "oWater")
    map_support = ("oMapfix", "oSampModels")

    map_wave_set = set(eligible)
    world_support_set = set(world_prep) | set(map_support)

    final: list[str] = []
    seen: set[str] = set()

    def push(nm: str) -> None:
        if nm not in seen:
            final.append(nm)
            seen.add(nm)

    for x in infra:
        push(x)
    for x in world_prep:
        push(x)
    for x in map_support:
        push(x)
    for x in eligible:
        push(x)

    # Ordem preservada dos não-map / mapas já movidos ou excluídos
    for x in tail:
        if x == "oPiruMap":
            x = "oPiruMapOLD"
        if x in seen:
            continue
        if x in map_wave_set and x != "oPiruMapOLD":
            continue
        if x in world_support_set:
            continue
        push(x)

    # Interior da tabela (entre `{` e `}`)
    new_inner = "".join(f'\t"{x}",\n' for x in final)
    rebuilt = raw[:inner_start] + "\n" + new_inner + raw[end_brace:]

    hdr = """  Regras desta revisão:
  - Duplicações triviais já consolidadas onde aplicável (`oBillboards` restart tardio).
  - **Mapas cedo**: após `oDestroyer`/`oWater`/`oMapfix`/`oSampModels`, carregar todos os
    recursos com `<map>` no `meta.xml` (conjunto menos exclusions em docs/tooling/rebuild_orp_map_wave.py),
    ordenados alfabéticamente.
  - `oPiruMap` foi substituído por **`oPiruMapOLD`** (recurso presente no pacote).
  - Removidos `oPlant`, `oPlaneCrash`, `gtavbahama` (não existem nesta árvore).
  - Perfis opcionais abaixo — `orpFilterStarterProfile` continua válido (`streamlined` remove dude_* maps).
"""

    rebuilt = re.sub(
        r"  Regras desta revisão:\n(?:  -[^\n]*\n)+",
        hdr,
        rebuilt,
        count=1,
    )

    MANI.write_text(rebuilt, encoding="utf-8")

    ib = final.index("oInfobox") if "oInfobox" in final else -1
    print(f"starter_names={len(items)} → {len(final)} | map_wave={len(eligible)} | oInfobox_índice={ib}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
