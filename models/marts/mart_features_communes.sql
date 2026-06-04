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
    coalesce(e.code_insee, t.code_insee, m.code_insee)                          as code_insee,
    coalesce(e.nom_commune, t.nom_commune, m.commune)                           as nom_commune,
    m.latitude,
    m.longitude,

    -- ── TERRITOIRE ────────────────────────────────────────────
    coalesce(t.code_departement,
        LEFT(coalesce(e.code_insee, t.code_insee, m.code_insee), 2))            as code_departement,
    coalesce(t.score_raccordement, 'Inconnu')                                   as score_raccordement,
    coalesce(t.nb_postes_rte, 0)                                                as nb_postes_rte,
    coalesce(t.nb_postes_htb, 0)                                                as nb_postes_htb,
    coalesce(t.surface_solaire_ha, 0)                                           as surface_solaire_ha,
    coalesce(t.surface_eolien_ha, 0)                                            as surface_eolien_ha,
    coalesce(t.surface_clc_ha, 0)                                               as surface_clc_ha,
    coalesce(t.surface_protegee_ha, 0)                                          as surface_protegee_ha,
    coalesce(t.nb_types_protection, 0)                                          as nb_types_protection,
    coalesce(t.has_natura2000, false)                                            as has_natura2000,
    coalesce(t.has_znieff, false)                                               as has_znieff,
    coalesce(t.has_parc_national, false)                                         as has_parc_national,
    coalesce(t.pct_territoire_protege, 0)                                        as pct_territoire_protege,
    coalesce(t.altitude_moy_m, 0)                                               as altitude_moy_m,
    coalesce(t.pente_moy_deg, 0)                                                as pente_moy_deg,
    coalesce(t.pente_max_deg, 0)                                                as pente_max_deg,
    coalesce(t.classe_pente_dominante, 'Inconnu')                               as classe_pente_dominante,
    coalesce(t.exposition_dominante, 'Inconnu')                                 as exposition_dominante,
    coalesce(t.favorable_solaire, false)                                         as favorable_solaire,
    coalesce(t.favorable_eolien, false)                                          as favorable_eolien,

    -- ── ENERGIE ───────────────────────────────────────────────
    coalesce(e.nb_habitants, 0)                                                 as nb_habitants,
    coalesce(e.conso_moy_periode_mwh, 0)                                        as conso_moy_periode_mwh,
    coalesce(e.conso_2017_mwh, 0)                                               as conso_2017_mwh,
    coalesce(e.conso_2018_mwh, 0)                                               as conso_2018_mwh,
    coalesce(e.conso_2019_mwh, 0)                                               as conso_2019_mwh,
    coalesce(e.conso_2020_mwh, 0)                                               as conso_2020_mwh,
    coalesce(e.conso_2021_mwh, 0)                                               as conso_2021_mwh,
    coalesce(e.conso_2022_mwh, 0)                                               as conso_2022_mwh,
    coalesce(e.conso_2023_mwh, 0)                                               as conso_2023_mwh,
    coalesce(e.conso_2024_mwh, 0)                                               as conso_2024_mwh,
    coalesce(e.evolution_conso_pct, 0)                                          as evolution_conso_pct,
    coalesce(e.puissance_solaire_mw, 0)                                         as puissance_solaire_mw,
    coalesce(e.puissance_eolien_mw, 0)                                          as puissance_eolien_mw,
    coalesce(e.puissance_totale_mw, 0)                                          as puissance_totale_mw,
    coalesce(e.nb_installations_pv, 0)                                          as nb_installations_pv,
    coalesce(e.nb_installations_eol, 0)                                         as nb_installations_eol,
    coalesce(e.energie_solaire_mwh_an, 0)                                       as energie_solaire_mwh_an,
    coalesce(e.energie_eolien_mwh_an, 0)                                        as energie_eolien_mwh_an,
    coalesce(e.energie_totale_mwh_an, 0)                                        as energie_totale_mwh_an,
    coalesce(e.statut_enr, 'Vierge')                                            as statut_enr,
    coalesce(e.taux_autonomie_pct, 0)                                           as taux_autonomie_pct,
    coalesce(e.surplus_mwh, 0)                                                  as surplus_mwh,
    coalesce(e.statut_autonomie, 'Déficitaire')                                 as statut_autonomie,
    coalesce(e.nb_installations_totales, 0)                                     as nb_installations_totales,
    coalesce(e.nb_sites_solaire, 0)                                             as nb_sites_solaire,
    coalesce(e.nb_sites_eolien, 0)                                              as nb_sites_eolien,
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
full outer join meteo m      on coalesce(e.code_insee, t.code_insee) = m.code_insee