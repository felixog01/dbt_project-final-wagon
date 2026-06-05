with source as (
    select * from {{ source('electricity', 'production_enr_dept_annuelle') }}
),

renamed as (
    select
        LPAD(cast(code_departement as string), 2, '0')      as code_departement,
        cast(annee as string)                               as annee,
        cast(nb_communes as int64)                          as nb_communes,
        cast(energie_solaire_mwh as float64)                as energie_solaire_mwh,
        cast(energie_eolien_mwh as float64)                 as energie_eolien_mwh,
        cast(energie_totale_mwh as float64)                 as energie_totale_mwh
    from source
    
)

select * from renamed