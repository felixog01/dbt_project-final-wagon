with scores as (
    select * from {{ ref('mart_score_communes') }}
)

select
    -- ── IDENTIFIANTS ──────────────────────────────────────────
    code_insee,
    nom_commune,
    latitude,
    longitude,
    code_departement,
    nom_departement,

    -- ── SCORES ────────────────────────────────────────────────
    score_solaire,
    score_eolien,
    eligible_solaire,
    eligible_eolien,
    technologie_dominante,
    classe_solaire,
    classe_eolien,

    score_composante_pvgis,
    score_composante_irradiation,
    score_composante_surface_sol,
    score_composante_pente,
    score_composante_vent,
    score_composante_productible,
    score_composante_surface_eol,
    score_composante_zones,
    score_composante_raccordement,
    score_composante_fiabilite_vent,

    -- ── SOLAIRE ───────────────────────────────────────────────
    production_kwh_kwc_an,
    irradiation_kwh_m2_an,
    viable_solaire,
    surface_solaire_ha,
    puissance_totale_mw                             as puissance_solaire_installee_mw,
    energie_totale_mwh_an                           as energie_solaire_produite_mwh,

    -- ── ÉOLIEN ────────────────────────────────────────────────
    wind_speed_moy_ms,
    productible_eolien_mwh_an,
    classe_vent,
    viable_eolien,
    fiabilite_vent,
    surface_eolien_ha,

    -- ── TERRITOIRE ────────────────────────────────────────────
    pente_moy_deg,
    altitude_moy_m,
    classe_pente_dominante,
    exposition_dominante,
    pct_territoire_protege,
    score_raccordement,
    has_natura2000,
    has_znieff,
    has_parc_national,
    has_pnr,
    has_reserve_naturelle,

    -- ── ÉNERGIE ───────────────────────────────────────────────
    nb_habitants,
    conso_moy_periode_mwh,
    conso_2017_mwh, conso_2018_mwh, conso_2019_mwh, conso_2020_mwh,
    conso_2021_mwh, conso_2022_mwh, conso_2023_mwh, conso_2024_mwh,
    evolution_conso_pct,
    taux_autonomie_pct,
    statut_autonomie,
    statut_enr,

    -- ── PRODUCTION PAR ANNÉE ──────────────────────────────────
    prod_sol_2017_mwh, prod_sol_2018_mwh, prod_sol_2019_mwh, prod_sol_2020_mwh,
    prod_sol_2021_mwh, prod_sol_2022_mwh, prod_sol_2023_mwh, prod_sol_2024_mwh,
    prod_eol_2017_mwh, prod_eol_2018_mwh, prod_eol_2019_mwh, prod_eol_2020_mwh,
    prod_eol_2021_mwh, prod_eol_2022_mwh, prod_eol_2023_mwh, prod_eol_2024_mwh,
    prod_tot_2017_mwh, prod_tot_2018_mwh, prod_tot_2019_mwh, prod_tot_2020_mwh,
    prod_tot_2021_mwh, prod_tot_2022_mwh, prod_tot_2023_mwh, prod_tot_2024_mwh,

    -- ── POTENTIEL ESTIMÉ (surfaces capées à un projet réaliste) ──
    -- Cap : 200 ha solaire (≈ très grande centrale) | 20 éoliennes max par commune
    round(least(surface_solaire_ha * 0.10, 200), 1)         as surface_installable_sol_ha,
    round(least(surface_solaire_ha * 0.10, 200), 1)         as puissance_installable_sol_mwc,
    round(
        least(surface_solaire_ha * 0.10, 200) * production_kwh_kwc_an / 1000
    , 0)                                                     as production_potentielle_sol_gwh,
    cast(least(surface_eolien_ha / 50, 20) as int64)        as nb_eoliennes_installables,
    round(
        least(surface_eolien_ha / 50, 20) * productible_eolien_mwh_an / 1000
    , 0)                                                     as production_potentielle_eol_gwh,

    -- ── RENTABILITÉ ───────────────────────────────────────────
    round(production_kwh_kwc_an * 55, 0)            as revenu_solaire_eur_par_mwc_an,
    round(productible_eolien_mwh_an * 72, 0)        as revenu_eolien_eur_par_machine_an,

    -- ── PRIX TERRAIN & FINANCIER ──────────────────────────────
    prix_terrain_median_eur_ha,
    prix_terrain_p25_eur_ha,
    prix_terrain_p75_eur_ha,

    round(least(surface_solaire_ha * 0.10, 200) * 1000 * 1050, 0)   as cout_install_sol_eur,
    round(least(surface_eolien_ha / 50, 20) * 2 * 1400000, 0)       as cout_install_eol_eur,
    round(least(surface_solaire_ha * 0.10, 200) * prix_terrain_median_eur_ha, 0) as cout_foncier_sol_eur,
    round(least(surface_eolien_ha, 1000) * 0.02 * prix_terrain_median_eur_ha, 0) as cout_foncier_eol_eur,
    round(
        least(surface_solaire_ha * 0.10, 200) * 1000 * 1050 +
        least(surface_solaire_ha * 0.10, 200) * prix_terrain_median_eur_ha, 0
    )                                                               as cout_total_sol_eur,
    round(
        least(surface_eolien_ha / 50, 20) * 2 * 1400000 +
        least(surface_eolien_ha, 1000) * 0.02 * prix_terrain_median_eur_ha, 0
    )                                                               as cout_total_eol_eur,
    round(safe_divide(
        least(surface_solaire_ha * 0.10, 200) * 1000 * 1050 +
        least(surface_solaire_ha * 0.10, 200) * prix_terrain_median_eur_ha,
        production_kwh_kwc_an * 55 * least(surface_solaire_ha * 0.10, 200)
    ), 1)                                                           as roi_sol_ans,
    round(safe_divide(
        least(surface_eolien_ha / 50, 20) * 2 * 1400000 +
        least(surface_eolien_ha, 1000) * 0.02 * prix_terrain_median_eur_ha,
        productible_eolien_mwh_an * 72 * least(surface_eolien_ha / 50, 20)
    ), 1)                                                           as roi_eol_ans

from scores
where code_departement not in ('97','98')
