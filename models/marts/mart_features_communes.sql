with territoire as (
    select * from {{ ref('int_features_territoire') }}
),

energie as (
    select * from {{ ref('int_features_energie') }}
),

meteo as (
    select * from {{ ref('int_features_meteo') }}
)

select
    -- Identifiants
    coalesce(e.code_insee, t.code_insee, m.code_insee)  as code_insee,
    coalesce(e.nom_commune, t.nom_commune, m.commune)   as nom_commune,
    m.latitude,
    m.longitude,

    -- ── TERRITOIRE ────────────────────────────────────────────
    t.code_departement,
    t.score_raccordement,
    t.nb_postes_rte,
    t.nb_postes_htb,
    t.surface_solaire_ha,
    t.surface_eolien_ha,
    t.surface_clc_ha,
    t.surface_protegee_ha,
    t.nb_types_protection,
    t.has_natura2000,
    t.has_znieff,
    t.has_parc_national,
    t.pct_territoire_protege,
    t.altitude_moy_m,
    t.pente_moy_deg,
    t.pente_max_deg,
    t.classe_pente_dominante,
    t.exposition_dominante,
    t.favorable_solaire,
    t.favorable_eolien,

    -- ── ENERGIE ───────────────────────────────────────────────
    e.nb_habitants,
    e.conso_moy_periode_mwh,
    e.conso_2017_mwh,
    e.conso_2018_mwh,
    e.conso_2019_mwh,
    e.conso_2020_mwh,
    e.conso_2021_mwh,
    e.conso_2022_mwh,
    e.conso_2023_mwh,
    e.conso_2024_mwh,
    e.evolution_conso_pct,
    e.puissance_solaire_mw,
    e.puissance_eolien_mw,
    e.puissance_totale_mw,
    e.nb_installations_pv,
    e.nb_installations_eol,
    e.energie_solaire_mwh_an,
    e.energie_eolien_mwh_an,
    e.energie_totale_mwh_an,
    e.statut_enr,
    e.taux_autonomie_pct,
    e.surplus_mwh,
    e.statut_autonomie,
    e.nb_installations_totales,
    e.premiere_installation,
    e.derniere_installation,

    -- ── MÉTÉO & RENDEMENTS ────────────────────────────────────
    m.production_kwh_kwc_an,
    m.irradiation_kwh_m2_an,
    m.performance_ratio_pct,
    m.classe_solaire,
    m.viable_solaire,
    m.radiation_moy_wh_m2_jour,
    m.sunshine_moy_h_jour,
    m.cloud_cover_moy_pct,
    m.wind_speed_moy_ms,
    m.wind_speed_max_ms,
    m.wind_p50,
    m.wind_p75,
    m.wind_p90,
    m.productible_eolien_mwh_an,
    m.facteur_charge_eolien_pct,
    m.classe_vent,
    m.viable_eolien,
    m.fiabilite_vent,
    m.rain_moy_mm_jour,
    m.tendance_radiation_wh_m2_par_an,
    m.radiation_2017_wh_m2,
    m.radiation_2018_wh_m2,
    m.radiation_2019_wh_m2,
    m.radiation_2020_wh_m2,
    m.radiation_2021_wh_m2,
    m.radiation_2022_wh_m2,
    m.radiation_2023_wh_m2,
    m.radiation_2024_wh_m2,
    m.radiation_2025_wh_m2

from energie e
full outer join territoire t on e.code_insee = t.code_insee
full outer join meteo m      on e.code_insee = m.code_insee