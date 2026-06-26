{{ config(materialized='view') }}

SELECT
    code_departement, nom_departement, annee,
    ROUND(SUM(prod_sol) / 1000, 1) as prod_sol_gwh,
    ROUND(SUM(prod_eol) / 1000, 1) as prod_eol_gwh,
    ROUND(SUM(prod_tot) / 1000, 1) as prod_tot_gwh,
    ROUND(SUM(conso) / 1000, 1) as conso_gwh,
    ROUND(SAFE_DIVIDE(SUM(prod_tot), SUM(conso)) * 100, 1) as taux_couverture_pct
FROM (
    SELECT code_departement, nom_departement, prod_sol_2017_mwh as prod_sol, prod_eol_2017_mwh as prod_eol, prod_tot_2017_mwh as prod_tot, conso_2017_mwh as conso, 2017 as annee FROM {{ ref('mart_dashboard') }}
    UNION ALL SELECT code_departement, nom_departement, prod_sol_2018_mwh, prod_eol_2018_mwh, prod_tot_2018_mwh, conso_2018_mwh, 2018 FROM {{ ref('mart_dashboard') }}
    UNION ALL SELECT code_departement, nom_departement, prod_sol_2019_mwh, prod_eol_2019_mwh, prod_tot_2019_mwh, conso_2019_mwh, 2019 FROM {{ ref('mart_dashboard') }}
    UNION ALL SELECT code_departement, nom_departement, prod_sol_2020_mwh, prod_eol_2020_mwh, prod_tot_2020_mwh, conso_2020_mwh, 2020 FROM {{ ref('mart_dashboard') }}
    UNION ALL SELECT code_departement, nom_departement, prod_sol_2021_mwh, prod_eol_2021_mwh, prod_tot_2021_mwh, conso_2021_mwh, 2021 FROM {{ ref('mart_dashboard') }}
    UNION ALL SELECT code_departement, nom_departement, prod_sol_2022_mwh, prod_eol_2022_mwh, prod_tot_2022_mwh, conso_2022_mwh, 2022 FROM {{ ref('mart_dashboard') }}
    UNION ALL SELECT code_departement, nom_departement, prod_sol_2023_mwh, prod_eol_2023_mwh, prod_tot_2023_mwh, conso_2023_mwh, 2023 FROM {{ ref('mart_dashboard') }}
    UNION ALL SELECT code_departement, nom_departement, prod_sol_2024_mwh, prod_eol_2024_mwh, prod_tot_2024_mwh, conso_2024_mwh, 2024 FROM {{ ref('mart_dashboard') }}
)
GROUP BY code_departement, nom_departement, annee
ORDER BY nom_departement, annee