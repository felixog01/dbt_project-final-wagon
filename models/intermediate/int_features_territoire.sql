with reseau as (
    select * from {{ ref('stg_reseau') }}
),

relief as (
    select * from {{ ref('stg_relief_commune') }}
),

occupation as (
    select * from {{ ref('stg_occupation_sols_commune') }}
),

zones as (
    select * from {{ ref('stg_zones_protegees_commune') }}
)

select
    r.code_insee,
    r.nom_commune,
    r.code_departement,

    -- Réseau électrique
    r.nb_postes_rte,
    r.nb_postes_htb,
    r.score_raccordement,

    -- Occupation des sols
    coalesce(o.surface_solaire_ha, 0)           as surface_solaire_ha,
    coalesce(o.surface_eolien_ha, 0)            as surface_eolien_ha,
    coalesce(o.surface_clc_ha, 0)               as surface_clc_ha,
    coalesce(o.nb_types_clc, 0)                 as nb_types_clc,

    -- Zones protégées
    coalesce(z.surface_protegee_ha, 0)          as surface_protegee_ha,
    coalesce(z.nb_types_protection, 0)          as nb_types_protection,
    coalesce(z.has_natura2000, false)            as has_natura2000,
    coalesce(z.has_znieff, false)               as has_znieff,
    coalesce(z.has_parc_national, false)         as has_parc_national,
    coalesce(z.pct_territoire_protege, 0)        as pct_territoire_protege,

    -- Relief
    coalesce(rl.altitude_moy_m, 0)              as altitude_moy_m,
    coalesce(rl.altitude_min_m, 0)              as altitude_min_m,
    coalesce(rl.altitude_max_m, 0)              as altitude_max_m,
    coalesce(rl.pente_moy_deg, 0)               as pente_moy_deg,
    coalesce(rl.pente_max_deg, 0)               as pente_max_deg,
    coalesce(rl.classe_pente_dominante, 'Inconnu') as classe_pente_dominante,
    coalesce(rl.exposition_dominante, 'Inconnu')   as exposition_dominante,
    coalesce(rl.favorable_solaire, false)           as favorable_solaire,
    coalesce(rl.favorable_eolien, false)            as favorable_eolien

from reseau r
left join occupation o  on r.code_insee = o.code_insee
left join zones z        on r.code_insee = z.code_insee
left join relief rl      on r.code_insee = rl.code_insee