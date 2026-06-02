with source as (
    select * from {{ source('infrastructure', 'tarifs_rachat_enr') }}
),

renamed as (
    select
        technologie,
        cast(tarif_rachat_eur_mwh as float64)   as tarif_rachat_eur_mwh,
        filiere,
        type
    from source
)

select * from renamed
