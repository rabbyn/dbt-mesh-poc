{#
  Cross-project ref() override for Fabric-based dbt Mesh.

  PROBLEM
  -------
  Native dbt Mesh cross-project ref('dbt_poc_che', 'fct_sales_order') resolves to
  the upstream model's *own* physical relation (e.g. gold_wh_che.sales.fct_sales_order),
  which lives in a different Fabric workspace. Fabric warehouses/lakehouses cannot
  execute cross-workspace SQL, so that relation is unusable at runtime. That is why
  this project historically used source() pointing at OneLake Shortcuts instead --
  but source() nodes are leaf nodes in dbt, so the dbt Explorer / Catalog lineage
  stopped at the shortcut and never connected back to the upstream country models.

  SOLUTION
  --------
  Use real cross-project ref('dbt_poc_che', '<model>') in the GLB models so dbt's
  static parser records the cross-project dependency edge (full end-to-end lineage),
  then remap ONLY the compiled physical relation to the local OneLake Shortcut so the
  SQL still runs entirely inside the GLB workspace.

  Shortcut layout (already provisioned in the GLB workspace staging lakehouses):
    gold_wh_che.sales    -> stg_lh_glb_sales.gold_che_sales
    gold_lh_ita.sales    -> stg_lh_glb_sales.gold_ita_sales
    gold_wh_che.finance  -> stg_lh_glb_finance.gold_che_finance
    gold_lh_ita.finance  -> stg_lh_glb_finance.gold_ita_finance

  dbt builds the lineage graph from the literal ref() arguments captured during the
  parse phase, independently of what this macro returns at compile time. So the
  cross-project edge is preserved even though the rendered relation is rewritten.

  Same-project refs and source() calls are passed straight through untouched.
#}
{% macro ref() %}
    {% set rel = builtins.ref(*varargs, **kwargs) %}

    {# Only 2-argument cross-project refs to our two upstream country projects #}
    {% if varargs | length >= 2 %}
        {% set project_name = varargs[0] %}
        {% set country_map = {'dbt_poc_che': 'che', 'dbt_poc_ita': 'ita'} %}

        {% if project_name in country_map %}
            {% set country = country_map[project_name] %}

            {# Derive the data domain (sales vs finance) from the upstream model name #}
            {% set finance_models = ['dim_account', 'dim_cost_center', 'fct_journal_entry'] %}
            {% set domain = 'finance' if rel.identifier in finance_models else 'sales' %}

            {% set staging_db = 'stg_lh_glb_' ~ domain %}
            {% set shortcut_schema = 'gold_' ~ country ~ '_' ~ domain %}

            {% do return(api.Relation.create(
                database=staging_db,
                schema=shortcut_schema,
                identifier=rel.identifier
            )) %}
        {% endif %}
    {% endif %}

    {% do return(rel) %}
{% endmacro %}
