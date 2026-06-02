with source as (
    select * from {{ source('infrastructure', 'reseau_commune') }}
),

renamed as (
    select
        cast(code_commune as string)        as code_insee,
        nom_commune,
        code_departement,
        cast(nb_postes_rte as int64)        as nb_postes_rte,
        cast(nb_postes_htb as int64)        as nb_postes_htb,
        score_raccordement
    from source
)

select * from renamed
