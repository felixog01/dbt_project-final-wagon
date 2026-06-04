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
-- Exclure les DOM
where code_departement not in ('971', '972', '973', '974', '975', '976', '977','978','984', '986','987','988', '989')
