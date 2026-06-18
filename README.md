# dbt Mesh PoC — Microsoft Fabric (dbt Cloud variant)

A multi-country **dbt Mesh** implementation on Microsoft Fabric, demonstrating cross-project, multi-domain data governance. Three dbt projects — Italy, Switzerland, and a Global aggregation layer — form a mesh where the Global project consumes the public *gold* models of each country project.

## Two implementation variants

This project is maintained in **two parallel variants**, one per branch, so the same data model can be run on either runtime:

| Branch | Runtime | Cross-project mechanism | Italy adapter |
|---|---|---|---|
| `main-core` | **dbt-core** (open-source CLI) | **dbt-loom** resolves cross-project refs from local manifests | `dbt-fabricspark` (Spark/Livy on Lakehouses) |
| `main-cloud` *(this branch)* | **dbt Cloud** | **native dbt Mesh** — `dependencies.yml` + `ref('project','model')` | `dbt-fabric` (T-SQL on Warehouses) |

> **Why Italy was refactored:** dbt Cloud does **not yet support the `dbt-fabricspark` adapter**. To run the full mesh on dbt Cloud, the Italy project (`dbt_poc_ita`) was refactored from Spark SQL on Lakehouses to **T-SQL on Fabric Warehouses** using the `dbt-fabric` adapter — so all three projects now use a single, dbt-Cloud-supported adapter.

## Overview

This branch uses **native dbt Mesh**: the Global project declares its upstream projects in `dependencies.yml` and references their public models with `{{ ref('dbt_poc_ita', '...') }}` / `{{ ref('dbt_poc_che', '...') }}`. dbt Cloud resolves these cross-project references automatically — no `dbt-loom` and no OneLake shortcuts are required.

| Project | Country | Adapter | Storage | Domains |
|---|---|---|---|---|
| `dbt_poc_ita` | Italy | `dbt-fabric` (T-SQL/TDS) | Warehouses `silver_wh_ita` / `gold_wh_ita` (Bronze stays Lakehouse `bronze_lh_ita`) | Sales, Finance |
| `dbt_poc_che` | Switzerland | `dbt-fabric` (T-SQL/TDS) | Warehouses (Bronze/Silver/Gold) | Sales, Finance |
| `dbt_poc_glb` | Global | `dbt-fabric` (T-SQL/TDS) | Warehouses (Gold Sales, Gold Finance) | Sales, Finance |

## Architecture

```
dbt_poc_ita (Italy)          dbt_poc_che (Switzerland)
  Bronze LH                    Bronze WH
      ↓                            ↓
  Silver WH                    Silver WH
      ↓                            ↓
  Gold WH ──────────────────── Gold WH
      │   (native dbt Mesh ref())   │
      └────────────┬───────────────┘
                   ↓
           dbt_poc_glb (Global)
              Gold WH (Sales)
              Gold WH (Finance)
```

### Cross-project integration (dbt Mesh + Fabric Shortcuts)

- `dbt_poc_glb/dependencies.yml` declares the upstream projects `dbt_poc_ita` and `dbt_poc_che` for dbt Cloud Mesh governance.
- Upstream gold models are exposed with `access: public` and `contract: { enforced: true }`.
- **Fabric cross-workspace constraint:** Fabric Warehouse does not support direct cross-workspace SQL queries. Native dbt Mesh `ref('dbt_poc_ita', '...')` would generate SQL like `gold_wh_ita.dbo_finance.dim_account` which Fabric rejects (different workspace). The GLB models therefore use `source()` routing through **Fabric Shortcuts** in the GLB workspace (`stg_lh_glb_sales`, `stg_lh_glb_finance`) that point to the upstream ITA/CHE gold schemas. `dependencies.yml` is kept for project-level Mesh governance and dbt Cloud's project registry.
- This pattern ("Fabric-compatible dbt Mesh") is the recommended approach for multi-workspace Fabric + dbt Cloud setups until Fabric supports cross-workspace SQL natively.

## Repository structure

```
dbt-mesh-poc/
├── dbt_poc_ita/           # Italy — dbt-fabric (Warehouse / T-SQL)
│   ├── models/
│   │   ├── silver/        # Staging layer (sales, finance)
│   │   └── gold/          # Gold layer (sales, finance) — access: public, contract: enforced
│   └── profiles.yml
├── dbt_poc_che/           # Switzerland — dbt-fabric (Warehouse / T-SQL)
│   ├── models/
│   │   ├── silver/
│   │   └── gold/          # access: public, contract: enforced
│   └── profiles.yml
├── dbt_poc_glb/           # Global — dbt-fabric (Warehouse / T-SQL)
│   ├── models/gold/       # Global gold layer (union of all countries via ref())
│   ├── dependencies.yml   # Native dbt Mesh: upstream projects
│   └── profiles.yml
├── scripts/               # Bronze seed scripts
│   ├── seed_bronze_che.sql
│   └── seed_bronze_ita.ipynb
├── .env.example
└── .gitignore
```

## Running on dbt Cloud

Each project is configured as its own **dbt Cloud project** pointing at its subfolder in this monorepo, all on the `main-cloud` branch.

1. In each dbt Cloud project, set the **Git branch** to `main-cloud` and the **project subdirectory** to the matching folder (`dbt_poc_ita`, `dbt_poc_che`, `dbt_poc_glb`).
2. Configure each connection against the corresponding Fabric Warehouse with **Service Principal** authentication.
3. Run order: country projects first (Italy, Switzerland), then Global.

```text
dbt build       # in dbt_poc_ita
dbt build       # in dbt_poc_che
dbt build       # in dbt_poc_glb   (resolves cross-project refs via dbt Mesh)
```

## Fabric / T-SQL conventions

- No bare `datetime` — use `datetime2(6)`.
- `current_timestamp()` (Spark) → `CAST(SYSUTCDATETIME() AS datetime2(6))`.
- `trim()` → `ltrim(rtrim())`; `cast(... as boolean)` → `cast(... as bit)`; `cast(... as timestamp)` → `cast(... as datetime2(6))`.
- Enforced contracts must declare T-SQL types (`varchar(n)`, `bit`, `datetime2(6)`, `decimal(18,2)`), not Spark types.

## Data domains

- **Sales**: `dim_client`, `dim_branch`, `fct_sales_order`
- **Finance**: `dim_account`, `dim_cost_center`, `fct_journal_entry`

Global models union both countries: `*_global` (e.g. `dim_account_global`, `fct_sales_order_global`).

## Notes

- All credentials are injected via environment variables / dbt Cloud connection settings; no secrets are stored in version-controlled files.
- The `documentation/`, `target/`, `dbt_packages/`, and `logs/` directories are excluded from version control.
