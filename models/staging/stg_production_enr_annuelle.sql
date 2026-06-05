with source as (
    select * from {{ source('electricity', 'production_enr_commune_annuelle') }}
),

renamed as (
    select
        LPAD(cast(code_commune as string), 5, '0')                          as code_insee,
        cast(annee as string)                                               as annee,
        cast(energie_solaire_mwh as float64)                                as energie_solaire_mwh,
        cast(energie_eolien_mwh as float64)                                 as energie_eolien_mwh,
        cast(energie_hydraulique_mwh as float64)                            as energie_hydraulique_mwh,
        cast(energie_bio_mwh as float64)                                    as energie_bio_mwh,
        coalesce(cast(energie_solaire_mwh as float64), 0) +
        coalesce(cast(energie_eolien_mwh as float64), 0) +
        coalesce(cast(energie_hydraulique_mwh as float64), 0) +
        coalesce(cast(energie_bio_mwh as float64), 0)                       as energie_totale_mwh,
        cast(nb_sites_solaire as int64)                                     as nb_sites_solaire,
        cast(nb_sites_eolien as int64)                                      as nb_sites_eolien
    from source
)

select * from renamed