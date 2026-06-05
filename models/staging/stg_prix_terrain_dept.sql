with source as (
    select * from {{ source('territoire', 'prix_terrain_agricole_dept') }}
),

renamed as (
    select
        LPAD(cast(code_dept as string), 2, '0')                             as code_departement,
        cast(prix_median_eur_ha as float64)                                 as prix_median_eur_ha,
        cast(prix_moy_eur_ha as float64)                                    as prix_moy_eur_ha,
        cast(prix_p25_eur_ha as float64)                                    as prix_p25_eur_ha,
        cast(prix_p75_eur_ha as float64)                                    as prix_p75_eur_ha,
        cast(nb_transactions as int64)                                      as nb_transactions
    from source
)

select * from renamed