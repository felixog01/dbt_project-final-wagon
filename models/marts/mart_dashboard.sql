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

    -- ── SCORES ────────────────────────────────────────────────
    score_solaire,
    score_eolien,
    score_global,
    technologie_recommandee,
    classe_score,
    eligible_solaire,
    eligible_eolien,

    -- Composantes scores
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
    classe_solaire,
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
    pct_territoire_protege,
    score_raccordement,
    has_natura2000,
    has_znieff,
    has_parc_national,
    has_pnr,
    has_reserve_naturelle,
    classe_pente_dominante,
    exposition_dominante,

    -- ── ÉNERGIE ───────────────────────────────────────────────
    nb_habitants,
    conso_moy_periode_mwh,
    taux_autonomie_pct,
    statut_autonomie,
    statut_enr,

    -- ── RENTABILITÉ ESTIMÉE ───────────────────────────────────
    round(production_kwh_kwc_an * 55, 0)            as revenu_solaire_eur_par_mwc_an,
    round(productible_eolien_mwh_an * 72, 0)        as revenu_eolien_eur_par_machine_an,

    -- ── POTENTIEL ESTIMÉ ──────────────────────────────────────
    round(surface_solaire_ha * 0.10, 1)             as surface_installable_sol_ha,
    round(surface_solaire_ha * 0.10 * 1, 1)         as puissance_installable_sol_mwc,
    round(
        surface_solaire_ha * 0.10 * production_kwh_kwc_an / 1000
    , 0)                                             as production_potentielle_sol_gwh,
    cast(surface_eolien_ha / 50 as int64)           as nb_eoliennes_installables,
    round(
        (surface_eolien_ha / 50) * productible_eolien_mwh_an / 1000
    , 0)                                             as production_potentielle_eol_gwh

from scores
where code_departement not in ('97','98')
