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
    prod_hydro_2017_mwh, prod_hydro_2018_mwh, prod_hydro_2019_mwh, prod_hydro_2020_mwh,
    prod_hydro_2021_mwh, prod_hydro_2022_mwh, prod_hydro_2023_mwh, prod_hydro_2024_mwh,
    prod_bio_2017_mwh, prod_bio_2018_mwh, prod_bio_2019_mwh, prod_bio_2020_mwh,
    prod_bio_2021_mwh, prod_bio_2022_mwh, prod_bio_2023_mwh, prod_bio_2024_mwh,
    prod_tot_2017_mwh, prod_tot_2018_mwh, prod_tot_2019_mwh, prod_tot_2020_mwh,
    prod_tot_2021_mwh, prod_tot_2022_mwh, prod_tot_2023_mwh, prod_tot_2024_mwh,

    -- ── PRIX TERRAIN & FINANCIER ──────────────────────────────
    prix_terrain_median_eur_ha,
    prix_terrain_p25_eur_ha,
    prix_terrain_p75_eur_ha,

    -- Coût installation solaire (1050 €/kWc)
    round(puissance_installable_sol_mwc * 1000 * 1050, 0)           as cout_install_sol_eur,

    -- Coût installation éolien (1.4M€/MW, 2MW/éolienne)
    round(nb_eoliennes_installables * 2 * 1400000, 0)               as cout_install_eol_eur,

    -- Coût foncier solaire
    round(surface_installable_sol_ha * prix_terrain_median_eur_ha, 0) as cout_foncier_sol_eur,

    -- Coût foncier éolien (2% surface)
    round(surface_eolien_ha * 0.02 * prix_terrain_median_eur_ha, 0) as cout_foncier_eol_eur,

    -- Coût total solaire
    round(
        puissance_installable_sol_mwc * 1000 * 1050 +
        surface_installable_sol_ha * prix_terrain_median_eur_ha, 0
    )                                                               as cout_total_sol_eur,

    -- Coût total éolien
    round(
        nb_eoliennes_installables * 2 * 1400000 +
        surface_eolien_ha * 0.02 * prix_terrain_median_eur_ha, 0
    )                                                               as cout_total_eol_eur,

    -- ROI solaire (années)
    round(safe_divide(
        puissance_installable_sol_mwc * 1000 * 1050 +
        surface_installable_sol_ha * prix_terrain_median_eur_ha,
        revenu_solaire_eur_par_mwc_an * puissance_installable_sol_mwc
    ), 1)                                                           as roi_sol_ans,

    -- ROI éolien (années)
    round(safe_divide(
        nb_eoliennes_installables * 2 * 1400000 +
        surface_eolien_ha * 0.02 * prix_terrain_median_eur_ha,
        revenu_eolien_eur_par_machine_an * nb_eoliennes_installables
    ), 1)                                                           as roi_eol_ans,

    -- ── POTENTIEL ESTIMÉ ──────────────────────────────────────
    round(surface_solaire_ha * 0.10, 1)             as surface_installable_sol_ha,
    round(surface_solaire_ha * 0.10 * 1, 1)         as puissance_installable_sol_mwc,
    round(
        surface_solaire_ha * 0.10 * production_kwh_kwc_an / 1000
    , 0)                                             as production_potentielle_sol_gwh,
    cast(surface_eolien_ha / 50 as int64)           as nb_eoliennes_installables,
    round(
        (surface_eolien_ha / 50) * productible_eolien_mwh_an / 1000
    , 0)                                             as production_potentielle_eol_gwh,

    -- ── RENTABILITÉ ───────────────────────────────────────────
    round(production_kwh_kwc_an * 55, 0)            as revenu_solaire_eur_par_mwc_an,
    round(productible_eolien_mwh_an * 72, 0)        as revenu_eolien_eur_par_machine_an

from scores
where code_departement not in ('97','98')
