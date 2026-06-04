with source as (
    select * from {{ source('electricity', 'production_enr_commune') }}
),

renamed as (
    select
        LPAD(cast(codeinseecommune as string), 5, '0')      as code_insee,
        cast(puissance_solaire_mw as float64)               as puissance_solaire_mw,
        cast(puissance_eolien_mw as float64)                as puissance_eolien_mw,
        cast(puissance_totale_mw as float64)                as puissance_totale_mw,
        cast(nb_installations_pv as int64)                  as nb_installations_pv,
        cast(nb_installations_eol as int64)                 as nb_installations_eol,
        cast(energie_solaire_mwh_an as float64)             as energie_solaire_mwh_an,
        cast(energie_eolien_mwh_an as float64)              as energie_eolien_mwh_an,
        cast(energie_totale_mwh_an as float64)              as energie_totale_mwh_an,
        statut_enr
    from source
)

select * from renamed