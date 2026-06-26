{{ config(materialized='view') }}

WITH agg AS (
    SELECT
        CAST(CAST(CONCAT(annee,'-01-01') AS STRING) AS DATE) as date_year,
        SUM(prod_sol) / 1e6 as prod_sol_twh,
        SUM(prod_eol) / 1e6 as prod_eol_twh,
        SUM(prod_tot) / 1e6 as prod_tot_twh,
        SUM(conso) / 1e6 as conso_twh
    FROM (
        SELECT prod_sol_2017_mwh as prod_sol, prod_eol_2017_mwh as prod_eol, prod_tot_2017_mwh as prod_tot, conso_2017_mwh as conso, 2017 as annee FROM {{ ref('mart_dashboard') }}
        UNION ALL SELECT prod_sol_2018_mwh, prod_eol_2018_mwh, prod_tot_2018_mwh, conso_2018_mwh, 2018 FROM {{ ref('mart_dashboard') }}
        UNION ALL SELECT prod_sol_2019_mwh, prod_eol_2019_mwh, prod_tot_2019_mwh, conso_2019_mwh, 2019 FROM {{ ref('mart_dashboard') }}
        UNION ALL SELECT prod_sol_2020_mwh, prod_eol_2020_mwh, prod_tot_2020_mwh, conso_2020_mwh, 2020 FROM {{ ref('mart_dashboard') }}
        UNION ALL SELECT prod_sol_2021_mwh, prod_eol_2021_mwh, prod_tot_2021_mwh, conso_2021_mwh, 2021 FROM {{ ref('mart_dashboard') }}
        UNION ALL SELECT prod_sol_2022_mwh, prod_eol_2022_mwh, prod_tot_2022_mwh, conso_2022_mwh, 2022 FROM {{ ref('mart_dashboard') }}
        UNION ALL SELECT prod_sol_2023_mwh, prod_eol_2023_mwh, prod_tot_2023_mwh, conso_2023_mwh, 2023 FROM {{ ref('mart_dashboard') }}
        UNION ALL SELECT prod_sol_2024_mwh, prod_eol_2024_mwh, prod_tot_2024_mwh, conso_2024_mwh, 2024 FROM {{ ref('mart_dashboard') }}
    )
    GROUP BY date_year
)
SELECT
    date_year,
    ROUND(prod_sol_twh, 2) as prod_sol_twh,
    ROUND(prod_eol_twh, 2) as prod_eol_twh,
    ROUND(prod_tot_twh, 2) as prod_tot_twh,
    ROUND(conso_twh, 2) as conso_twh,
    ROUND(SAFE_DIVIDE(prod_tot_twh, conso_twh) * 100, 1) as taux_couverture_pct,
    ROUND(prod_tot_twh / FIRST_VALUE(prod_tot_twh) OVER (ORDER BY date_year) * 100, 1) as indice_prod_base100,
    ROUND(conso_twh / FIRST_VALUE(conso_twh) OVER (ORDER BY date_year) * 100, 1) as indice_conso_base100
FROM agg
ORDER BY date_year