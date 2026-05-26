"""
patch_glb_manifest.py

Post-processes dbt_poc_glb/target/manifest.json to add cross-project lineage
edges that are lost because GLB models use source() refs to OneLake shortcuts
instead of ref('dbt_poc_ita', ...) / ref('dbt_poc_che', ...).

dbt-loom already injects the upstream model nodes into the manifest, but no
edges connect them to the GLB models. This script adds those edges so that
dbt Power User (and any tool reading the manifest) shows full cross-project
lineage.

Run after every `dbt parse` in dbt_poc_glb:
    python scripts/patch_glb_manifest.py

Or chain it:
    cd dbt_poc_glb && dbt parse --profiles-dir . && cd .. && python scripts/patch_glb_manifest.py
"""

import json
from pathlib import Path

MANIFEST_PATH = Path(__file__).parent.parent / "dbt_poc_glb" / "target" / "manifest.json"

# Maps source name (as defined in _upstream_sources.yml) to the upstream dbt project name.
# The table name is preserved — source('ita_gold_finance', 'dim_account')
#   → model.dbt_poc_ita.dim_account
SOURCE_TO_PROJECT = {
    "ita_gold_finance": "dbt_poc_ita",
    "ita_gold_sales":   "dbt_poc_ita",
    "che_gold_finance": "dbt_poc_che",
    "che_gold_sales":   "dbt_poc_che",
}


def patch_manifest() -> None:
    if not MANIFEST_PATH.exists():
        raise FileNotFoundError(f"Manifest not found: {MANIFEST_PATH}\nRun `dbt parse --profiles-dir .` inside dbt_poc_glb first.")

    with open(MANIFEST_PATH, encoding="utf-8") as f:
        manifest = json.load(f)

    nodes      = manifest.get("nodes", {})
    parent_map = manifest.get("parent_map", {})
    child_map  = manifest.get("child_map", {})

    patched_models = 0
    edges_added    = 0

    for node_id, node in nodes.items():
        # Only process GLB gold models
        if not node_id.startswith("model.dbt_poc_glb."):
            continue

        existing_deps: list = node.setdefault("depends_on", {}).setdefault("nodes", [])
        new_upstream: list  = []
        rewritten_deps: list = []

        for dep in existing_deps:
            # dep looks like:  source.dbt_poc_glb.ita_gold_finance.dim_account
            # Replace source refs with the actual upstream model ref so lineage
            # chains through stg→dim instead of stopping at a source node.
            if dep.startswith("source.dbt_poc_glb."):
                parts = dep.split(".")
                if len(parts) == 4:
                    source_name = parts[2]   # e.g. ita_gold_finance
                    table_name  = parts[3]   # e.g. dim_account
                    upstream_project = SOURCE_TO_PROJECT.get(source_name)
                    if upstream_project:
                        upstream_node_id = f"model.{upstream_project}.{table_name}"
                        if upstream_node_id in nodes:
                            if upstream_node_id not in rewritten_deps:
                                rewritten_deps.append(upstream_node_id)
                                new_upstream.append(upstream_node_id)
                                print(f"  ~ {node_id.split('.')[-1]}  {dep.split('.',2)[-1]}  →  {upstream_node_id}")
                                edges_added += 1
                            # Drop the source ref — replaced by the model ref above
                            continue
                        else:
                            print(f"  WARN: {upstream_node_id} not found in manifest — keeping source ref")
            rewritten_deps.append(dep)

        if new_upstream:
            node["depends_on"]["nodes"] = rewritten_deps
            patched_models += 1

            # Keep parent_map in sync: remove old source refs, add model refs
            parent_map[node_id] = [
                d for d in parent_map.get(node_id, [])
                if not d.startswith("source.dbt_poc_glb.")
            ]
            for u in new_upstream:
                if u not in parent_map[node_id]:
                    parent_map[node_id].append(u)

            # Keep child_map in sync
            for u in new_upstream:
                child_map.setdefault(u, [])
                if node_id not in child_map[u]:
                    child_map[u].append(node_id)

    manifest["parent_map"] = parent_map
    manifest["child_map"]  = child_map

    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    print(f"\nDone. {edges_added} cross-project edges added across {patched_models} GLB models.")
    print(f"Manifest saved: {MANIFEST_PATH}")


if __name__ == "__main__":
    patch_manifest()
