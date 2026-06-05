with prod as (
    select * from {{ ref('stg_production_enr_annuelle') }}
)

select
    code_insee,

    -- ── SOLAIRE PAR ANNÉE ─────────────────────────────────────
    max(case when annee = '2017' then energie_solaire_mwh else 0 end)   as prod_sol_2017_mwh,
    max(case when annee = '2018' then energie_solaire_mwh else 0 end)   as prod_sol_2018_mwh,
    max(case when annee = '2019' then energie_solaire_mwh else 0 end)   as prod_sol_2019_mwh,
    max(case when annee = '2020' then energie_solaire_mwh else 0 end)   as prod_sol_2020_mwh,
    max(case when annee = '2021' then energie_solaire_mwh else 0 end)   as prod_sol_2021_mwh,
    max(case when annee = '2022' then energie_solaire_mwh else 0 end)   as prod_sol_2022_mwh,
    max(case when annee = '2023' then energie_solaire_mwh else 0 end)   as prod_sol_2023_mwh,
    max(case when annee = '2024' then energie_solaire_mwh else 0 end)   as prod_sol_2024_mwh,

    -- ── ÉOLIEN PAR ANNÉE ──────────────────────────────────────
    max(case when annee = '2017' then energie_eolien_mwh else 0 end)    as prod_eol_2017_mwh,
    max(case when annee = '2018' then energie_eolien_mwh else 0 end)    as prod_eol_2018_mwh,
    max(case when annee = '2019' then energie_eolien_mwh else 0 end)    as prod_eol_2019_mwh,
    max(case when annee = '2020' then energie_eolien_mwh else 0 end)    as prod_eol_2020_mwh,
    max(case when annee = '2021' then energie_eolien_mwh else 0 end)    as prod_eol_2021_mwh,
    max(case when annee = '2022' then energie_eolien_mwh else 0 end)    as prod_eol_2022_mwh,
    max(case when annee = '2023' then energie_eolien_mwh else 0 end)    as prod_eol_2023_mwh,
    max(case when annee = '2024' then energie_eolien_mwh else 0 end)    as prod_eol_2024_mwh,

    -- ── TOTAL PAR ANNÉE ───────────────────────────────────────
    max(case when annee = '2017' then energie_totale_mwh else 0 end)    as prod_tot_2017_mwh,
    max(case when annee = '2018' then energie_totale_mwh else 0 end)    as prod_tot_2018_mwh,
    max(case when annee = '2019' then energie_totale_mwh else 0 end)    as prod_tot_2019_mwh,
    max(case when annee = '2020' then energie_totale_mwh else 0 end)    as prod_tot_2020_mwh,
    max(case when annee = '2021' then energie_totale_mwh else 0 end)    as prod_tot_2021_mwh,
    max(case when annee = '2022' then energie_totale_mwh else 0 end)    as prod_tot_2022_mwh,
    max(case when annee = '2023' then energie_totale_mwh else 0 end)    as prod_tot_2023_mwh,
    max(case when annee = '2024' then energie_totale_mwh else 0 end)    as prod_tot_2024_mwh,

    -- ── NB SITES ──────────────────────────────────────────────
    max(case when annee = '2024' then nb_sites_solaire else 0 end)      as nb_sites_solaire,
    max(case when annee = '2024' then nb_sites_eolien else 0 end)       as nb_sites_eolien

from prod
group by code_insee