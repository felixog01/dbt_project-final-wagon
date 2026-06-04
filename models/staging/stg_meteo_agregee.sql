with source as (
    select * from {{ source('data_meteo', 'meteo_agregee_commune') }}
),

renamed as (
    select
        LPAD(cast(code_insee as string), 5, '0')                    as code_insee,
        commune,
        cast(latitude as float64)                                   as latitude,
        cast(longitude as float64)                                  as longitude,
        cast(radiation_moy_wh_m2_jour as float64)                   as radiation_moy_wh_m2_jour,
        cast(radiation_total_wh_m2 as float64)                      as radiation_total_wh_m2,
        cast(sunshine_moy_h_jour as float64)                        as sunshine_moy_h_jour,
        cast(cloud_cover_moy_pct as float64)                        as cloud_cover_moy_pct,
        cast(wind_speed_moy_ms as float64)                          as wind_speed_moy_ms,
        cast(wind_speed_max_ms as float64)                          as wind_speed_max_ms,
        cast(wind_p50 as float64)                                   as wind_p50,
        cast(wind_p75 as float64)                                   as wind_p75,
        cast(wind_p90 as float64)                                   as wind_p90,
        cast(tendance_radiation_wh_m2_par_an as float64)            as tendance_radiation_wh_m2_par_an,
        cast(radiation_2017_wh_m2 as float64)                       as radiation_2017_wh_m2,
        cast(radiation_2018_wh_m2 as float64)                       as radiation_2018_wh_m2,
        cast(radiation_2019_wh_m2 as float64)                       as radiation_2019_wh_m2,
        cast(radiation_2020_wh_m2 as float64)                       as radiation_2020_wh_m2,
        cast(radiation_2021_wh_m2 as float64)                       as radiation_2021_wh_m2,
        cast(radiation_2022_wh_m2 as float64)                       as radiation_2022_wh_m2,
        cast(radiation_2023_wh_m2 as float64)                       as radiation_2023_wh_m2,
        cast(radiation_2024_wh_m2 as float64)                       as radiation_2024_wh_m2,
        cast(radiation_2025_wh_m2 as float64)                       as radiation_2025_wh_m2
    from source
)

select * from renamed