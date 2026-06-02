with source as (
    select * from {{ source('infrastructure', 'installations_enr') }}
),

renamed as (
    select
        cast(codeinseecommune as string)                    as code_insee,
        commune,
        departement,
        codedepartement                                     as code_departement,
        filiere,
        codefiliere                                         as code_filiere,
        technologie,
        cast(puismaxinstallee as float64)                   as puissance_installee_kw,
        cast(nbinstallations as int64)                      as nb_installations,
        regime,
        cast(energieannuelleglissanteinjectee as float64)   as energie_injectee_kwh_an,
        postesource                                         as poste_source,
        tensionraccordement                                 as tension_raccordement,
        datemiseenservice                                   as date_mise_en_service
    from source
)

select * from renamed