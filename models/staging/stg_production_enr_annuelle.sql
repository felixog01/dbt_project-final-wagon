with source as (
    select * from {{ source('electricity', 'production_enr_commune_annuelle') }}
),

renamed as (
    select
        LPAD(cast(code_commune as string), 5, '0')          as code_insee,
        cast(annee as string)                               as annee,
        cast(energie_solaire_mwh as float64)                as energie_solaire_mwh,
        cast(energie_eolien_mwh as float64)                 as energie_eolien_mwh,
        cast(energie_totale_mwh as float64)                 as energie_totale_mwh
    from source
)

select * from renamed