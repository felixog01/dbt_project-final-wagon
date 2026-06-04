with source as (
    select * from {{ source('electricity', 'consommation_commune') }}
),

renamed as (
    select
        LPAD(cast(code_commune as string), 5, '0')          as code_insee,
        nom_commune,
        code_departement,
        cast(annee as int64)                                as annee,
        cast(conso_totale_mwh as float64)                   as conso_totale_mwh,
        cast(conso_moyenne_mwh as float64)                  as conso_moyenne_mwh,
        cast(nb_sites as int64)                             as nb_sites,
        cast(nombre_d_habitants as int64)                   as nb_habitants,
        code_grand_secteur
    from source
)

select * from renamed