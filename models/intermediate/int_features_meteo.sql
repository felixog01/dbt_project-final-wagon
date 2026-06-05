with pvgis as (
    select * from {{ ref('stg_pvgis') }}
),
meteo as (
    select * from {{ ref('stg_meteo') }}
),
meteo_agregee as (
    select * from {{ ref('stg_meteo_agregee') }}
)
select
    CASE m.code_insee
        WHEN '12076' THEN '12218'
        WHEN '49069' THEN '49126'
        WHEN '28349' THEN '76601'
        WHEN '33401' THEN '85212'
        ELSE m.code_insee
    END                                                         as code_insee,
    m.commune,
    m.latitude,
    m.longitude,

    -- Production solaire : PVGIS uniquement, PAS de fallback éolien
    -- Si PVGIS null, estimer depuis irradiation (ratio ~0.78)
    coalesce(
        p.production_kwh_kwc_an,
        round(coalesce(p.irradiation_kwh_m2_an, m.irradiation_kwh_m2_an) * 0.78, 1)
    )                                                           as production_kwh_kwc_an,
    coalesce(p.irradiation_kwh_m2_an, m.irradiation_kwh_m2_an)  as irradiation_kwh_m2_an,
    coalesce(p.performance_ratio_pct, m.performance_ratio_pct)  as performance_ratio_pct,

    m.classe_solaire,
    m.viable_solaire,
    m.radiation_moy_wh_m2_jour,
    m.radiation_total_wh_m2,
    m.sunshine_moy_h_jour,
    m.cloud_cover_moy_pct,
    m.rain_moy_mm_jour,
    m.nb_jours,

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

    ma.tendance_radiation_wh_m2_par_an,
    ma.radiation_2017_wh_m2,
    ma.radiation_2018_wh_m2,
    ma.radiation_2019_wh_m2,
    ma.radiation_2020_wh_m2,
    ma.radiation_2021_wh_m2,
    ma.radiation_2022_wh_m2,
    ma.radiation_2023_wh_m2,
    ma.radiation_2024_wh_m2,
    ma.radiation_2025_wh_m2

from meteo as m
left join pvgis as p          on m.code_insee = p.code_insee
left join meteo_agregee as ma on m.code_insee = ma.code_insee
where m.production_kwh_kwc_an is not null
and   m.wind_speed_moy_ms     is not null
