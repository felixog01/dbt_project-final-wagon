with source as (
    select * from {{ source('territoire', 'occupation_sols_commune') }}
),

renamed as (
    select
        LPAD(cast(code_insee as string), 5, '0')            as code_insee,
        nom_commune,
        cast(surface_clc_ha as float64)                     as surface_clc_ha,
        cast(nb_types_clc as int64)                         as nb_types_clc,
        cast(surface_solaire_ha as float64)                 as surface_solaire_ha,
        cast(surface_eolien_ha as float64)                  as surface_eolien_ha
    from source
)

select * from renamed