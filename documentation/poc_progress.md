# dbt-mesh POC - Progress & Status

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────────┐
│  dbt_poc_ita    │    │  dbt_poc_che    │    │  dbt_poc_glb                │
│  (Italy)        │    │  (Switzerland)  │    │  (Global)                   │
│                 │    │                 │    │                             │
│  Adapter:       │    │  Adapter:       │    │  Adapter: dbt-fabric        │
│  dbt-fabricspark│    │  dbt-fabric     │    │  Plugin:  dbt-loom          │
│  (Spark/Livy)   │    │  (T-SQL/TDS)    │    │  (cross-project refs)       │
│                 │    │                 │    │                             │
│  Target:        │    │  Target:        │    │  Target:                    │
│  lh_poc_ita_*   │    │  wh_poc_che     │    │  wh_poc_glb_sales           │
│  (Lakehouses)   │    │  (Warehouse)    │    │  wh_poc_glb_finance         │
└────────┬────────┘    └────────┬────────┘    └──────────────┬──────────────┘
         │                      │                            │
         │  manifest.json       │  manifest.json             │
         └──────────────────────┴────────────────────────────┘
                         dbt-loom (metadata DAG)
```

## What Has Been Done

### 1. Environment Setup ✅
- Python 3.13 venv at `.venv/`
- Installed: `dbt-core 1.11.11`, `dbt-fabric 1.10.0`, `dbt-fabricspark 1.12.3`, `dbt-loom 0.9.4`
- `.env` file with all Fabric workspace/item IDs, SQL endpoints, and SPN credentials

### 2. Italy Project (`dbt_poc_ita/`) ✅ Scaffolded | ⚠️ Blocked at runtime
- 6 silver models (Spark SQL): `stg_account`, `stg_branch`, `stg_client`, `stg_cost_center`, `stg_journal_entry`, `stg_sales_order`
- 6 gold models (Spark SQL): `dim_account`, `dim_branch`, `dim_client`, `dim_cost_center`, `fct_journal_entry`, `fct_sales_order`
- Source definitions for bronze layer + data tests (unique, not_null)
- `profiles.yml` configured for fabricspark adapter with CLI auth
- **`dbt parse` succeeded** → `target/manifest.json` generated (needed by dbt-loom)
- **Runtime BLOCKED**: Zscaler SSL interception prevents `api.fabric.microsoft.com` API calls from CLI
- Bronze data seeded via Fabric portal (PySpark notebook `scripts/seed_bronze_ita.ipynb`)

### 3. Switzerland Project (`dbt_poc_che/`) ✅ FULLY WORKING
- 6 silver models (T-SQL): same entities as Italy
- 6 gold models (T-SQL): same entities as Italy
- Source definitions + 28 data tests
- `profiles.yml` configured for fabric adapter with CLI auth
- Bronze data seeded via `scripts/seed_bronze_che.sql` (run in Fabric portal)
- **`dbt run` → 12/12 models PASS** ✅
- **`dbt test` → 28/28 tests PASS** ✅

### 4. Global Project (`dbt_poc_glb/`) 🔄 In Progress
- 6 gold models doing `UNION ALL` of ITA + CHE data
- `dbt_loom.config.yml` configured to read ITA and CHE manifests
- Models use `{{ source('ita_gold', ...) }}` and `{{ source('che_gold', ...) }}` 
- Source definitions in `models/sources/_upstream_sources.yml`
- **`dbt parse` succeeded** ✅
- **Awaiting**: seed script to populate `ita_gold.*` and `che_gold.*` schemas in `wh_poc_glb_sales`

### 5. Fabric Items Created ✅
| Workspace | Item | Type |
|-----------|------|------|
| EMEA_GDP_POC_ITADBT | lh_poc_ita_bronze | Lakehouse |
| EMEA_GDP_POC_ITADBT | lh_poc_ita_silver | Lakehouse |
| EMEA_GDP_POC_ITADBT | lh_poc_ita_gold | Lakehouse |
| EMEA_GDP_POC_CHEDBT | wh_poc_che | Warehouse |
| EMEA_GDP_POC_GLBDBT | wh_poc_glb_sales | Warehouse |
| EMEA_GDP_POC_GLBDBT | wh_poc_glb_finance | Warehouse |

## What Remains To Be Done

### Immediate Next Steps

#### A. Seed Global Warehouse Sources (5 min)
Run `scripts/seed_gold_glb.py` to create `ita_gold` and `che_gold` schemas in `wh_poc_glb_sales` with representative data simulating Fabric shortcuts.

**Prerequisite**: Load env vars in terminal first:
```powershell
Get-Content .env | ForEach-Object { if ($_ -match '^([^#=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process') } }
```

Then run:
```powershell
.venv\Scripts\python.exe scripts\seed_gold_glb.py
```

#### B. Run Global dbt Models (2 min)
```powershell
cd dbt_poc_glb
..\\.venv\Scripts\dbt.exe run --profiles-dir .
..\\.venv\Scripts\dbt.exe test --profiles-dir .
```

#### C. Run Italy Models (Manual - Fabric Portal)
Since Zscaler blocks `api.fabric.microsoft.com` from CLI, Italy models must be run from:
- **Option 1**: Fabric portal → Notebook (paste the dbt commands)
- **Option 2**: A machine without Zscaler proxy
- **Option 3**: Switch Italy to use SPN auth (may bypass Zscaler for the Livy API)

### Optional Enhancements
- [ ] Switch all profiles from CLI auth to SPN auth (SPN creds now in `.env`)
- [ ] Add model contracts back to Global models (removed due to dbt-fabric quoting bug)
- [ ] Create actual Fabric Shortcuts instead of seeded tables for production pattern
- [ ] Add CI/CD pipeline (Azure DevOps) for automated dbt runs
- [ ] Add dbt docs generation and hosting

## Key Learnings / Fabric DW Compatibility

| Issue | Fix Applied |
|-------|-------------|
| `datetime` type not supported | Use `datetime2(6)` |
| `getutcdate()` returns unsupported `datetime` | Use `SYSUTCDATETIME()` |
| `SYSUTCDATETIME()` returns `datetime2(7)` (precision 7 not allowed) | Wrap in `CAST(... AS datetime2(6))` |
| dbt-loom cross-project `ref()` with same adapter | Double-brackets bug → use `source()` pattern instead |
| Cross-workspace queries in Fabric | Require Fabric Shortcuts (or staging tables for POC) |
| dbt-loom config filename | Must be `dbt_loom.config.yml` (underscore, not hyphen) |

## File Structure
```
dbt-mesh-poc/
├── .env                          # All Fabric IDs, endpoints, SPN creds
├── .venv/                        # Python virtual environment
├── dbt_poc_ita/                  # Italy project (fabricspark)
│   ├── dbt_project.yml
│   ├── profiles.yml
│   └── models/
│       ├── silver/               # 6 staging models (Spark SQL)
│       └── gold/                 # 6 dimensional models (Spark SQL)
├── dbt_poc_che/                  # Switzerland project (fabric)
│   ├── dbt_project.yml
│   ├── profiles.yml
│   └── models/
│       ├── silver/               # 6 staging models (T-SQL)
│       └── gold/                 # 6 dimensional models (T-SQL)
├── dbt_poc_glb/                  # Global project (fabric + dbt-loom)
│   ├── dbt_project.yml
│   ├── profiles.yml
│   ├── dbt_loom.config.yml       # Cross-project manifest references
│   └── models/
│       ├── sources/              # Upstream source definitions
│       └── gold/                 # 6 union models (T-SQL)
├── scripts/
│   ├── seed_bronze_che.sql       # Bronze data for Switzerland (run in portal)
│   ├── seed_bronze_ita.ipynb     # Bronze data for Italy (run in portal)
│   ├── seed_gold_glb.sql         # Raw SQL version of GLB seed
│   └── seed_gold_glb.py          # Python script to seed GLB sources via SPN
└── documentation/
    └── dbt_cloud_poc_requirements.md
```
