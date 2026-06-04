with source as (
    select * from {{ source('electricity', 'pvgis_all_communes') }}
),

renamed as (
    select
        LPAD(cast(code_insee as string), 5, '0')            as code_insee,
        cast(latitude as float64)                           as latitude,
        cast(longitude as float64)                          as longitude,
        cast(production_kwh_kwc_an as float64)              as production_kwh_kwc_an,
        cast(irradiation_kwh_m2_an as float64)              as irradiation_kwh_m2_an,
        cast(performance_ratio_pct as float64)              as performance_ratio_pct
    from source
)

select * from renamed