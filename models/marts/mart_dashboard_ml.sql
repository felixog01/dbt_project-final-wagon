{{ config(materialized='view') }}

SELECT d.*,
    ml.cluster_solaire, ml.cluster_eolien, ml.profil_solaire, ml.profil_eolien,
    ml.pred_prod_2030_mwh, ml.pred_prod_2035_mwh, ml.pred_prod_2040_mwh,
    ml.tendance_prod_mwh_an, ml.fiabilite_tendance_r2
FROM {{ ref('mart_dashboard') }} d
LEFT JOIN `project-final-wagon.dbt_fortizgonthier_marts.mart_ml_communes` ml
    ON d.code_insee = ml.code_insee