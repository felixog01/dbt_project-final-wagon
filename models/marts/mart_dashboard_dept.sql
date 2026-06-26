{{ config(materialized='view') }}

SELECT
    code_departement,
    nom_departement,
    COUNT(*) as nb_communes,
    SUM(nb_habitants) as population,
    AVG(latitude) as latitude,
    AVG(longitude) as longitude,
    ROUND(AVG(score_solaire), 1) as score_solaire_moy,
    ROUND(AVG(score_eolien), 1) as score_eolien_moy,
    ROUND(AVG(score_solaire_ajuste), 1) as score_solaire_ajuste_moy,
    ROUND(AVG(score_eolien_ajuste), 1) as score_eolien_ajuste_moy,
    COUNTIF(eligible_solaire) as nb_eligibles_solaire,
    COUNTIF(eligible_eolien) as nb_eligibles_eolien,
    SUM(nb_installations_pv) as nb_installations_pv,
    SUM(nb_installations_eol) as nb_installations_eol,
    ROUND(SUM(puissance_solaire_installee_mw), 0) as sol_installe_mw,
    ROUND(SUM(puissance_eolien_installee_mw), 0) as eol_installe_mw,
    ROUND(SUM(prod_sol_2024_mwh) / 1000, 0) as prod_sol_2024_gwh,
    ROUND(SUM(prod_eol_2024_mwh) / 1000, 0) as prod_eol_2024_gwh,
    ROUND(SUM(production_potentielle_sol_gwh), 0) as potentiel_sol_gwh,
    ROUND(SUM(production_potentielle_eol_gwh), 0) as potentiel_eol_gwh,
    ROUND(SUM(production_realiste_sol_gwh), 0) as potentiel_realiste_sol_gwh,
    ROUND(SUM(production_realiste_eol_gwh), 0) as potentiel_realiste_eol_gwh,
    ROUND(SAFE_DIVIDE(SUM(puissance_solaire_installee_mw),
        SUM(puissance_solaire_installee_mw) + SUM(puissance_installable_sol_mwc)) * 100, 1) as taux_equip_sol_pct,
    ROUND(SAFE_DIVIDE(SUM(puissance_eolien_installee_mw),
        SUM(puissance_eolien_installee_mw) + SUM(nb_eoliennes_installables * 2)) * 100, 1) as taux_equip_eol_pct,
    ROUND(AVG(prix_terrain_median_eur_ha), 0) as prix_terrain_moy_eur_ha
FROM {{ ref('mart_dashboard') }}
GROUP BY code_departement, nom_departement