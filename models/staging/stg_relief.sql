with source as (
    select * from {{ source('territoire', 'relief') }}
),

renamed as (
    select
        cast(lon as float64)            as longitude,
        cast(lat as float64)            as latitude,
        cast(altitude_m as float64)     as altitude_m,
        cast(pente_deg as float64)      as pente_deg,
        classe_pente,
        exposition,
        geometry_wkt
    from source
)

select * from renamed
