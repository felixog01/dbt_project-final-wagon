with source as (
    select * from {{ source('territoire', 'relief_commune') }}
),

renamed as (
    select
        LPAD(cast(code_insee as string), 5, '0')            as code_insee,
        nom_commune,
        cast(altitude_moy_m as float64)                     as altitude_moy_m,
        cast(altitude_min_m as float64)                     as altitude_min_m,
        cast(altitude_max_m as float64)                     as altitude_max_m,
        cast(pente_moy_deg as float64)                      as pente_moy_deg,
        cast(pente_min_deg as float64)                      as pente_min_deg,
        cast(pente_max_deg as float64)                      as pente_max_deg,
        classe_pente_dominante,
        exposition_dominante,
        cast(nb_points_relief as int64)                     as nb_points_relief,
        cast(favorable_solaire as bool)                     as favorable_solaire,
        cast(favorable_eolien as bool)                      as favorable_eolien
    from source
)

select * from renamed
qualify row_number() over (partition by code_insee order by code_insee) = 1