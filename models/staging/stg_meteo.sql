with source as (
    select * from {{ source('data_meteo', 'meteo_rendement_commune') }}
),

renamed as (
    select
        LPAD(cast(code_insee as string), 5, '0')            as code_insee,
        commune,
        cast(latitude as float64)                           as latitude,
        cast(longitude as float64)                          as longitude,
        cast(radiation_moy_wh_m2_jour as float64)           as radiation_moy_wh_m2_jour,
        cast(radiation_total_wh_m2 as float64)              as radiation_total_wh_m2,
        cast(sunshine_moy_h_jour as float64)                as sunshine_moy_h_jour,
        cast(sunshine_total_h as float64)                   as sunshine_total_h,
        cast(cloud_cover_moy_pct as float64)                as cloud_cover_moy_pct,
        cast(wind_speed_moy_ms as float64)                  as wind_speed_moy_ms,
        cast(wind_speed_max_ms as float64)                  as wind_speed_max_ms,
        cast(wind_p50 as float64)                           as wind_p50,
        cast(wind_p75 as float64)                           as wind_p75,
        cast(wind_p90 as float64)                           as wind_p90,
        cast(rain_moy_mm_jour as float64)                   as rain_moy_mm_jour,
        cast(nb_jours as int64)                             as nb_jours,
        cast(production_kwh_kwc_an as float64)              as production_kwh_kwc_an,
        cast(irradiation_kwh_m2_an as float64)              as irradiation_kwh_m2_an,
        cast(performance_ratio_pct as float64)              as performance_ratio_pct,
        classe_solaire,
        cast(viable_solaire as bool)                        as viable_solaire,
        cast(productible_eolien_mwh_an as float64)          as productible_eolien_mwh_an,
        cast(facteur_charge_eolien_pct as float64)          as facteur_charge_eolien_pct,
        classe_vent,
        cast(viable_eolien as bool)                         as viable_eolien,
        fiabilite_vent
    from source
)

select * from renamed