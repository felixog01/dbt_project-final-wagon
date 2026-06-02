with source as (
    select * from {{ source('territoire', 'zones_protegees') }}
),

renamed as (
    select
        type_protection,
        code_site,
        nom_site,
        statut_legal,
        source                          as source_donnee,
        cast(surface_ha as float64)     as surface_ha,
        date_extraction,
        geometry_wkt
    from source
)

select * from renamed