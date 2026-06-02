with source as (
    select * from {{ source('territoire', 'occupation_sols') }}
),

renamed as (
    select
        code_clc,
        label_clc,
        categorie,
        contrainte_construction,
        cast(surface_ha as float64)     as surface_ha,
        geometry_wkt
    from source
)

select * from renamed