with territoire as (
    select * from {{ ref('int_features_territoire') }}
),
energie as (
    select * from {{ ref('int_features_energie') }}
),
meteo as (
    select * from {{ ref('int_features_meteo') }}
),
production_annuelle as (
    select * from {{ ref('int_features_production_annuelle') }}
),
prix_terrain as (
    select * from {{ ref('stg_prix_terrain_dept') }}
)

select
    -- ── IDENTIFIANTS ──────────────────────────────────────────
    coalesce(e.code_insee, t.code_insee, m.code_insee)              as code_insee,
    coalesce(e.nom_commune, t.nom_commune, m.commune)               as nom_commune,
    m.latitude,
    m.longitude,

    -- ── DÉPARTEMENT ───────────────────────────────────────────
    coalesce(t.code_departement,
        LEFT(coalesce(e.code_insee, t.code_insee, m.code_insee), 2))    as code_departement,

    case coalesce(t.code_departement,
        LEFT(coalesce(e.code_insee, t.code_insee, m.code_insee), 2))
        WHEN '01' THEN '01 - Ain'
        WHEN '02' THEN '02 - Aisne'
        WHEN '03' THEN '03 - Allier'
        WHEN '04' THEN '04 - Alpes-de-Haute-Provence'
        WHEN '05' THEN '05 - Hautes-Alpes'
        WHEN '06' THEN '06 - Alpes-Maritimes'
        WHEN '07' THEN '07 - Ardèche'
        WHEN '08' THEN '08 - Ardennes'
        WHEN '09' THEN '09 - Ariège'
        WHEN '10' THEN '10 - Aube'
        WHEN '11' THEN '11 - Aude'
        WHEN '12' THEN '12 - Aveyron'
        WHEN '13' THEN '13 - Bouches-du-Rhône'
        WHEN '14' THEN '14 - Calvados'
        WHEN '15' THEN '15 - Cantal'
        WHEN '16' THEN '16 - Charente'
        WHEN '17' THEN '17 - Charente-Maritime'
        WHEN '18' THEN '18 - Cher'
        WHEN '19' THEN '19 - Corrèze'
        WHEN '2A' THEN '2A - Corse-du-Sud'
        WHEN '2B' THEN '2B - Haute-Corse'
        WHEN '21' THEN '21 - Côte-d\''Or'
        WHEN '22' THEN '22 - Côtes-d\''Armor'
        WHEN '23' THEN '23 - Creuse'
        WHEN '24' THEN '24 - Dordogne'
        WHEN '25' THEN '25 - Doubs'
        WHEN '26' THEN '26 - Drôme'
        WHEN '27' THEN '27 - Eure'
        WHEN '28' THEN '28 - Eure-et-Loir'
        WHEN '29' THEN '29 - Finistère'
        WHEN '30' THEN '30 - Gard'
        WHEN '31' THEN '31 - Haute-Garonne'
        WHEN '32' THEN '32 - Gers'
        WHEN '33' THEN '33 - Gironde'
        WHEN '34' THEN '34 - Hérault'
        WHEN '35' THEN '35 - Ille-et-Vilaine'
        WHEN '36' THEN '36 - Indre'
        WHEN '37' THEN '37 - Indre-et-Loire'
        WHEN '38' THEN '38 - Isère'
        WHEN '39' THEN '39 - Jura'
        WHEN '40' THEN '40 - Landes'
        WHEN '41' THEN '41 - Loir-et-Cher'
        WHEN '42' THEN '42 - Loire'
        WHEN '43' THEN '43 - Haute-Loire'
        WHEN '44' THEN '44 - Loire-Atlantique'
        WHEN '45' THEN '45 - Loiret'
        WHEN '46' THEN '46 - Lot'
        WHEN '47' THEN '47 - Lot-et-Garonne'
        WHEN '48' THEN '48 - Lozère'
        WHEN '49' THEN '49 - Maine-et-Loire'
        WHEN '50' THEN '50 - Manche'
        WHEN '51' THEN '51 - Marne'
        WHEN '52' THEN '52 - Haute-Marne'
        WHEN '53' THEN '53 - Mayenne'
        WHEN '54' THEN '54 - Meurthe-et-Moselle'
        WHEN '55' THEN '55 - Meuse'
        WHEN '56' THEN '56 - Morbihan'
        WHEN '57' THEN '57 - Moselle'
        WHEN '58' THEN '58 - Nièvre'
        WHEN '59' THEN '59 - Nord'
        WHEN '60' THEN '60 - Oise'
        WHEN '61' THEN '61 - Orne'
        WHEN '62' THEN '62 - Pas-de-Calais'
        WHEN '63' THEN '63 - Puy-de-Dôme'
        WHEN '64' THEN '64 - Pyrénées-Atlantiques'
        WHEN '65' THEN '65 - Hautes-Pyrénées'
        WHEN '66' THEN '66 - Pyrénées-Orientales'
        WHEN '67' THEN '67 - Bas-Rhin'
        WHEN '68' THEN '68 - Haut-Rhin'
        WHEN '69' THEN '69 - Rhône'
        WHEN '70' THEN '70 - Haute-Saône'
        WHEN '71' THEN '71 - Saône-et-Loire'
        WHEN '72' THEN '72 - Sarthe'
        WHEN '73' THEN '73 - Savoie'
        WHEN '74' THEN '74 - Haute-Savoie'
        WHEN '75' THEN '75 - Paris'
        WHEN '76' THEN '76 - Seine-Maritime'
        WHEN '77' THEN '77 - Seine-et-Marne'
        WHEN '78' THEN '78 - Yvelines'
        WHEN '79' THEN '79 - Deux-Sèvres'
        WHEN '80' THEN '80 - Somme'
        WHEN '81' THEN '81 - Tarn'
        WHEN '82' THEN '82 - Tarn-et-Garonne'
        WHEN '83' THEN '83 - Var'
        WHEN '84' THEN '84 - Vaucluse'
        WHEN '85' THEN '85 - Vendée'
        WHEN '86' THEN '86 - Vienne'
        WHEN '87' THEN '87 - Haute-Vienne'
        WHEN '88' THEN '88 - Vosges'
        WHEN '89' THEN '89 - Yonne'
        WHEN '90' THEN '90 - Territoire de Belfort'
        WHEN '91' THEN '91 - Essonne'
        WHEN '92' THEN '92 - Hauts-de-Seine'
        WHEN '93' THEN '93 - Seine-Saint-Denis'
        WHEN '94' THEN '94 - Val-de-Marne'
        WHEN '95' THEN '95 - Val-d\''Oise'
        ELSE coalesce(t.code_departement,
            LEFT(coalesce(e.code_insee, t.code_insee, m.code_insee), 2))
    end                                                             as nom_departement,

    -- ── TERRITOIRE ────────────────────────────────────────────
    coalesce(t.score_raccordement, 'Inconnu')                       as score_raccordement,
    coalesce(t.nb_postes_rte, 0)                                    as nb_postes_rte,
    coalesce(t.nb_postes_htb, 0)                                    as nb_postes_htb,
    coalesce(t.surface_solaire_ha, 0)                               as surface_solaire_ha,
    coalesce(t.surface_eolien_ha, 0)                                as surface_eolien_ha,
    coalesce(t.surface_clc_ha, 0)                                   as surface_clc_ha,
    coalesce(t.surface_protegee_ha, 0)                              as surface_protegee_ha,
    coalesce(t.nb_types_protection, 0)                              as nb_types_protection,
    coalesce(t.has_natura2000, false)                               as has_natura2000,
    coalesce(t.has_znieff, false)                                   as has_znieff,
    coalesce(t.has_parc_national, false)                            as has_parc_national,
    coalesce(t.has_pnr, false)                                      as has_pnr,
    coalesce(t.has_reserve_naturelle, false)                        as has_reserve_naturelle,
    coalesce(t.pct_territoire_protege, 0)                           as pct_territoire_protege,
    coalesce(t.altitude_moy_m, 0)                                   as altitude_moy_m,
    coalesce(t.altitude_min_m, 0)                                   as altitude_min_m,
    coalesce(t.altitude_max_m, 0)                                   as altitude_max_m,
    coalesce(t.pente_moy_deg, 0)                                    as pente_moy_deg,
    coalesce(t.pente_max_deg, 0)                                    as pente_max_deg,
    coalesce(t.classe_pente_dominante, 'Inconnu')                   as classe_pente_dominante,
    coalesce(t.exposition_dominante, 'Inconnu')                     as exposition_dominante,
    coalesce(t.favorable_solaire, false)                            as favorable_solaire,
    coalesce(t.favorable_eolien, false)                             as favorable_eolien,

    -- ── ENERGIE ───────────────────────────────────────────────
    coalesce(e.nb_habitants, 0)                                     as nb_habitants,
    coalesce(e.conso_moy_periode_mwh, 0)                            as conso_moy_periode_mwh,
    coalesce(e.conso_2017_mwh, 0)                                   as conso_2017_mwh,
    coalesce(e.conso_2018_mwh, 0)                                   as conso_2018_mwh,
    coalesce(e.conso_2019_mwh, 0)                                   as conso_2019_mwh,
    coalesce(e.conso_2020_mwh, 0)                                   as conso_2020_mwh,
    coalesce(e.conso_2021_mwh, 0)                                   as conso_2021_mwh,
    coalesce(e.conso_2022_mwh, 0)                                   as conso_2022_mwh,
    coalesce(e.conso_2023_mwh, 0)                                   as conso_2023_mwh,
    coalesce(e.conso_2024_mwh, 0)                                   as conso_2024_mwh,
    coalesce(e.evolution_conso_pct, 0)                              as evolution_conso_pct,
    coalesce(e.puissance_solaire_mw, 0)                             as puissance_solaire_mw,
    coalesce(e.puissance_eolien_mw, 0)                              as puissance_eolien_mw,
    coalesce(e.puissance_totale_mw, 0)                              as puissance_totale_mw,
    coalesce(e.nb_installations_pv, 0)                              as nb_installations_pv,
    coalesce(e.nb_installations_eol, 0)                             as nb_installations_eol,
    coalesce(e.energie_solaire_mwh_an, 0)                           as energie_solaire_mwh_an,
    coalesce(e.energie_eolien_mwh_an, 0)                            as energie_eolien_mwh_an,
    coalesce(e.energie_totale_mwh_an, 0)                            as energie_totale_mwh_an,
    coalesce(e.statut_enr, 'Vierge')                                as statut_enr,
    coalesce(e.taux_autonomie_pct, 0)                               as taux_autonomie_pct,
    coalesce(e.surplus_mwh, 0)                                      as surplus_mwh,
    coalesce(e.statut_autonomie, 'Déficitaire')                     as statut_autonomie,
    coalesce(e.nb_installations_totales, 0)                         as nb_installations_totales,
    coalesce(e.nb_sites_solaire, 0)                                 as nb_sites_solaire,
    coalesce(e.nb_sites_eolien, 0)                                  as nb_sites_eolien,
    e.premiere_installation,
    e.derniere_installation,

-- ── PRODUCTION PAR ANNÉE ──────────────────────────────────
    coalesce(pa.prod_sol_2017_mwh, 0)               as prod_sol_2017_mwh,
    coalesce(pa.prod_sol_2018_mwh, 0)               as prod_sol_2018_mwh,
    coalesce(pa.prod_sol_2019_mwh, 0)               as prod_sol_2019_mwh,
    coalesce(pa.prod_sol_2020_mwh, 0)               as prod_sol_2020_mwh,
    coalesce(pa.prod_sol_2021_mwh, 0)               as prod_sol_2021_mwh,
    coalesce(pa.prod_sol_2022_mwh, 0)               as prod_sol_2022_mwh,
    coalesce(pa.prod_sol_2023_mwh, 0)               as prod_sol_2023_mwh,
    coalesce(pa.prod_sol_2024_mwh, 0)               as prod_sol_2024_mwh,
    coalesce(pa.prod_eol_2017_mwh, 0)               as prod_eol_2017_mwh,
    coalesce(pa.prod_eol_2018_mwh, 0)               as prod_eol_2018_mwh,
    coalesce(pa.prod_eol_2019_mwh, 0)               as prod_eol_2019_mwh,
    coalesce(pa.prod_eol_2020_mwh, 0)               as prod_eol_2020_mwh,
    coalesce(pa.prod_eol_2021_mwh, 0)               as prod_eol_2021_mwh,
    coalesce(pa.prod_eol_2022_mwh, 0)               as prod_eol_2022_mwh,
    coalesce(pa.prod_eol_2023_mwh, 0)               as prod_eol_2023_mwh,
    coalesce(pa.prod_eol_2024_mwh, 0)               as prod_eol_2024_mwh,
    coalesce(pa.prod_hydro_2017_mwh, 0)             as prod_hydro_2017_mwh,
    coalesce(pa.prod_hydro_2018_mwh, 0)             as prod_hydro_2018_mwh,
    coalesce(pa.prod_hydro_2019_mwh, 0)             as prod_hydro_2019_mwh,
    coalesce(pa.prod_hydro_2020_mwh, 0)             as prod_hydro_2020_mwh,
    coalesce(pa.prod_hydro_2021_mwh, 0)             as prod_hydro_2021_mwh,
    coalesce(pa.prod_hydro_2022_mwh, 0)             as prod_hydro_2022_mwh,
    coalesce(pa.prod_hydro_2023_mwh, 0)             as prod_hydro_2023_mwh,
    coalesce(pa.prod_hydro_2024_mwh, 0)             as prod_hydro_2024_mwh,
    coalesce(pa.prod_bio_2017_mwh, 0)               as prod_bio_2017_mwh,
    coalesce(pa.prod_bio_2018_mwh, 0)               as prod_bio_2018_mwh,
    coalesce(pa.prod_bio_2019_mwh, 0)               as prod_bio_2019_mwh,
    coalesce(pa.prod_bio_2020_mwh, 0)               as prod_bio_2020_mwh,
    coalesce(pa.prod_bio_2021_mwh, 0)               as prod_bio_2021_mwh,
    coalesce(pa.prod_bio_2022_mwh, 0)               as prod_bio_2022_mwh,
    coalesce(pa.prod_bio_2023_mwh, 0)               as prod_bio_2023_mwh,
    coalesce(pa.prod_bio_2024_mwh, 0)               as prod_bio_2024_mwh,
    coalesce(pa.prod_tot_2017_mwh, 0)               as prod_tot_2017_mwh,
    coalesce(pa.prod_tot_2018_mwh, 0)               as prod_tot_2018_mwh,
    coalesce(pa.prod_tot_2019_mwh, 0)               as prod_tot_2019_mwh,
    coalesce(pa.prod_tot_2020_mwh, 0)               as prod_tot_2020_mwh,
    coalesce(pa.prod_tot_2021_mwh, 0)               as prod_tot_2021_mwh,
    coalesce(pa.prod_tot_2022_mwh, 0)               as prod_tot_2022_mwh,
    coalesce(pa.prod_tot_2023_mwh, 0)               as prod_tot_2023_mwh,
    coalesce(pa.prod_tot_2024_mwh, 0)               as prod_tot_2024_mwh,
    -- ── PRIX TERRAIN ──────────────────────────────────────────
    coalesce(pt.prix_median_eur_ha, 0)                                      as prix_terrain_median_eur_ha,
    coalesce(pt.prix_p25_eur_ha, 0)                                         as prix_terrain_p25_eur_ha,
    coalesce(pt.prix_p75_eur_ha, 0)                                         as prix_terrain_p75_eur_ha,
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
left join production_annuelle pa on coalesce(e.code_insee, t.code_insee, m.code_insee) = pa.code_insee
left join prix_terrain pt        on coalesce(t.code_departement,
    LEFT(coalesce(e.code_insee, t.code_insee, m.code_insee), 2)) = pt.code_departement

-- Exclure les DOM
where coalesce(t.code_departement,
    LEFT(coalesce(e.code_insee, t.code_insee, m.code_insee), 2))
    not in ('971', '972', '973', '974', '976')