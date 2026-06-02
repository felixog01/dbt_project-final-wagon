with source as (
    select * from {{ source('electricity', 'consommation_commune_multi_annees') }}
),

renamed as (
    select
        cast(code_commune as string)                as code_insee,
        nom_commune,
        cast(conso_moy_periode_mwh as float64)      as conso_moy_periode_mwh,
        cast(nb_habitants as int64)                 as nb_habitants,
        cast(conso_2017_mwh as float64)             as conso_2017_mwh,
        cast(conso_2018_mwh as float64)             as conso_2018_mwh,
        cast(conso_2019_mwh as float64)             as conso_2019_mwh,
        cast(conso_2020_mwh as float64)             as conso_2020_mwh,
        cast(conso_2021_mwh as float64)             as conso_2021_mwh,
        cast(conso_2022_mwh as float64)             as conso_2022_mwh,
        cast(conso_2023_mwh as float64)             as conso_2023_mwh,
        cast(conso_2024_mwh as float64)             as conso_2024_mwh,
        cast(evolution_conso_pct as float64)        as evolution_conso_pct
    from source
)

select * from renamed
