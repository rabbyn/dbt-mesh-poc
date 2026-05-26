# dbt Mesh PoC — Microsoft Fabric

A **dbt Mesh** implementation across Microsoft Fabric Warehouse and Lakehouse — demonstrating cross-adapter, multi-domain data governance at scale. The mesh spans two dbt adapters (`dbt-fabric` for T-SQL Warehouses and `dbt-fabricspark` for Spark Lakehouses), two country-level projects, and a global aggregation layer consuming upstream gold models via OneLake shortcuts.

## Overview

This repository contains three dbt projects that together form a mesh:

| Project | Country | Adapter | Storage | Domains |
|---|---|---|---|---|
| `dbt_poc_ita` | Italy | `dbt-fabricspark` (Livy) | Lakehouses (Bronze/Silver/Gold) | Sales, Finance |
| `dbt_poc_che` | Switzerland | `dbt-fabric` (T-SQL/TDS) | Warehouses (Bronze/Silver/Gold) | Sales, Finance |
| `dbt_poc_glb` | Global | `dbt-fabric` (T-SQL/TDS) | Warehouses (Gold Sales, Gold Finance) | Sales, Finance |

The Global project (`dbt_poc_glb`) consumes gold-layer models from both country projects via **OneLake schema shortcuts** and **dbt-loom** for cross-project model references.

## Architecture

```
dbt_poc_ita (Italy)          dbt_poc_che (Switzerland)
  Bronze LH                    Bronze WH
      ↓                            ↓
  Silver LH                    Silver WH
      ↓                            ↓
  Gold LH ──────────────────── Gold WH
      │   (OneLake shortcuts)      │
      └────────────┬───────────────┘
                   ↓
           dbt_poc_glb (Global)
              Gold WH (Sales)
              Gold WH (Finance)
```

### Cross-project Integration

- **dbt-loom**: `dbt_poc_glb` reads manifests from `dbt_poc_ita` and `dbt_poc_che` to reference upstream public models directly.
- **OneLake Shortcuts**: Two staging lakehouses (`stg_lh_glb_finance`, `stg_lh_glb_sales`) in the Global workspace hold schema shortcuts pointing to upstream country workspaces, allowing the Warehouse SQL engine to resolve cross-database references.

## Repository Structure

```
dbt-mesh-poc/
├── dbt_poc_ita/           # Italy — dbt-fabricspark (Lakehouse / Spark / Livy)
│   ├── models/
│   │   ├── silver/        # Staging layer (sales, finance)
│   │   └── gold/          # Gold layer (sales, finance)
│   └── profiles.yml
├── dbt_poc_che/           # Switzerland — dbt-fabric (Warehouse / T-SQL)
│   ├── models/
│   │   ├── silver/        # Staging layer (sales, finance)
│   │   └── gold/          # Gold layer (sales, finance)
│   └── profiles.yml
├── dbt_poc_glb/           # Global — dbt-fabric (Warehouse / T-SQL)
│   ├── models/
│   │   ├── sources/       # Upstream source definitions (OneLake shortcuts)
│   │   └── gold/          # Global gold layer (union of all countries)
│   ├── dbt_loom.config.yml
│   └── profiles.yml
├── scripts/               # Seed and utility scripts
│   ├── seed_bronze_che.sql
│   ├── seed_bronze_ita.ipynb
│   ├── seed_gold_glb.sql
│   └── patch_glb_manifest.py
├── .env.example           # Environment variable template
└── .gitignore
```

## Prerequisites

- Python 3.11+
- [ODBC Driver 18 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
- A Microsoft Fabric tenant with three workspaces provisioned:
  - `EMEA_GDP_DBT_POC_ITA`
  - `EMEA_GDP_POC_DBT_CHE`
  - `EMEA_GDP_POC_DBT_GLB`
- A Service Principal with **Workspace Admin** role on all three workspaces

## Setup

### 1. Clone the repository

```bash
git clone <repo-url>
cd dbt-mesh-poc
```

### 2. Create a virtual environment

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

### 3. Install dbt adapters

```powershell
pip install dbt-fabric dbt-fabricspark
```

### 4. Configure environment variables

Copy `.env.example` to `.env` and fill in your Fabric workspace and service principal values:

```powershell
Copy-Item .env.example .env
```

Required variables:

| Variable | Description |
|---|---|
| `FABRIC_TENANT_ID` | Azure AD tenant ID |
| `FABRIC_SPN_CLIENT_ID` | Service principal client ID |
| `FABRIC_SPN_CLIENT_SECRET` | Service principal client secret |
| `FABRIC_WS_ITA_ID` | Italy workspace ID |
| `FABRIC_LH_ITA_BRONZE_ID` | Italy Bronze Lakehouse ID |
| `FABRIC_LH_ITA_SILVER_ID` | Italy Silver Lakehouse ID |
| `FABRIC_LH_ITA_GOLD_ID` | Italy Gold Lakehouse ID |
| `FABRIC_WS_CHE_ID` | Switzerland workspace ID |
| `FABRIC_WH_CHE_BRONZE_ID` | Switzerland Bronze Warehouse ID |
| `FABRIC_WH_CHE_SILVER_ID` | Switzerland Silver Warehouse ID |
| `FABRIC_WH_CHE_GOLD_ID` | Switzerland Gold Warehouse ID |
| `FABRIC_WH_CHE_SERVER` | Switzerland Warehouse TDS server FQDN |
| `FABRIC_WS_GLB_ID` | Global workspace ID |
| `FABRIC_WH_GLB_GOLD_SALES_ID` | Global Gold Sales Warehouse ID |
| `FABRIC_WH_GLB_GOLD_FINANCE_ID` | Global Gold Finance Warehouse ID |
| `FABRIC_WH_GLB_SERVER` | Global Warehouse TDS server FQDN |

### 5. Load environment variables

```powershell
Get-Content .env | ForEach-Object {
  if ($_ -match '^\s*([^#=][^=]*)=(.*)$') {
    [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
  }
}
```

## Running the Projects

Each project is run independently. Always run country projects before the Global project.

### Italy (dbt-fabricspark)

```bash
cd dbt_poc_ita
dbt deps
dbt run
dbt test
```

### Switzerland (dbt-fabric)

```bash
cd dbt_poc_che
dbt deps
dbt run
dbt test
```

### Global (dbt-fabric + dbt-loom)

> Requires `dbt_poc_ita` and `dbt_poc_che` to have been compiled first (manifests must exist in their `target/` folders).

```bash
cd dbt_poc_glb
dbt deps
dbt run
dbt test
```

## Data Domains

Each country project exposes two domains:

- **Sales**: `dim_client`, `dim_branch`, `fct_sales_order`
- **Finance**: `dim_account`, `dim_cost_center`, `fct_journal_entry`

The Global project unions both country sources into consolidated global models:

- `dim_account_global`, `dim_cost_center_global`, `fct_journal_entry_global`
- `dim_client_global`, `dim_branch_global`, `fct_sales_order_global`

## Seeding Bronze Data

Seed scripts are available in the `scripts/` folder:

- **Switzerland** (Warehouse): `seed_bronze_che.sql`
- **Italy** (Lakehouse/Spark): `seed_bronze_ita.ipynb`
- **Global** (post-run validation): `seed_gold_glb.sql`, `seed_gold_glb.py`

## Notes

- The `dbt_poc_glb` project uses [`dbt-loom`](https://github.com/nicholasgasior/dbt-loom) — configured in `dbt_loom.config.yml` — to resolve cross-project model references from local manifest files.
- All credentials are injected via environment variables; no secrets are stored in version-controlled files.
- The `documentation/` folder and dbt `target/`, `dbt_packages/`, and `logs/` directories are excluded from version control.
