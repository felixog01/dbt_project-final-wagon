with source as (
    select * from {{ source('data_meteo', 'meteo_france_communes') }}
),

renamed as (
    select
        LPAD(cast(code_insee as string), 5, '0')            as code_insee,
        commune,
        cast(latitude as float64)                           as latitude,
        cast(longitude as float64)                          as longitude,
        cast(date as date)                                  as date,
        cast(sunshine_duration as float64)                  as sunshine_duration,
        cast(shortwave_radiation_sum as float64)            as shortwave_radiation_sum,
        cast(wind_speed_10m_mean as float64)                as wind_speed_10m_mean,
        cast(wind_speed_10m_max as float64)                 as wind_speed_10m_max,
        cast(cloud_cover_mean as float64)                   as cloud_cover_mean,
        cast(rain_sum as float64)                           as rain_sum
    from source
)

select * from renamed