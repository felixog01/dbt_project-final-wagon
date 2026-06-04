with source as (
    select * from {{ source('territoire', 'zones_protegees_commune') }}
),

renamed as (
    select
        LPAD(cast(code_insee as string), 5, '0')            as code_insee,
        cast(surface_protegee_ha as float64)                as surface_protegee_ha,
        cast(nb_types_protection as int64)                  as nb_types_protection,
        cast(has_natura2000 as bool)                        as has_natura2000,
        cast(has_znieff as bool)                            as has_znieff,
        cast(has_parc_national as bool)                     as has_parc_national,
        cast(pct_territoire_protege as float64)             as pct_territoire_protege
    from source
)

select * from renamed