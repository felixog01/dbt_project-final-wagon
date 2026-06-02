with source as (
    select * from {{ source('electricity', 'autonomie_energetique') }}
),

renamed as (
    select
        cast(code_commune as string)                as code_insee,
        nom_commune,
        cast(conso_moy_periode_mwh as float64)      as conso_moy_periode_mwh,
        cast(nb_habitants as int64)                 as nb_habitants,
        cast(puissance_solaire_mw as float64)       as puissance_solaire_mw,
        cast(puissance_eolien_mw as float64)        as puissance_eolien_mw,
        cast(puissance_totale_mw as float64)        as puissance_totale_mw,
        cast(energie_totale_mwh_an as float64)      as energie_totale_mwh_an,
        cast(taux_autonomie_pct as float64)         as taux_autonomie_pct,
        cast(surplus_mwh as float64)                as surplus_mwh,
        statut_autonomie,
        statut_enr
    from source
)

select * from renamed
