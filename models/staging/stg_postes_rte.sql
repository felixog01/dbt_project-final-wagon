with source as (
    select * from {{ source('infrastructure', 'postes_rte_dept') }}
),

renamed as (
    select
        departement,
        cast(nb_postes_rte as int64)        as nb_postes_rte,
        cast(nb_postes_htb as int64)        as nb_postes_htb,
        tensions_disponibles,
        score_raccordement,
        code_departement
    from source
)

select * from renamed
