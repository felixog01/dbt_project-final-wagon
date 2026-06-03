/*select 
a.code_insee, 
sum(a.puissance_solaire_mw) as puissance_solaire_mw, 
sum(a.puissance_eolien_mw) as puissance_eolien_mw,
sum(i.nb_installations) as nb_installations,
sum(a.taux_autonomie_pct) as taux_autonomie_pct,
round((a.conso_moy_periode_mwh),2) as conso_moy_periode_mwh,
c.evolution_conso_pct ,
case when a.statut_enr = '0' then 'vierge' ELSE statut_enr END AS statut_enr
from {{ ref("stg_autonomie") }}  as a
left join {{ ref('stg_installations_enr') }} as i
on a.code_insee = i.code_insee
left join {{ ref('stg_consommation') }} as c
on i.code_insee = c.code_insee
group by a.code_insee, c.evolution_conso_pct, a.conso_moy_periode_mwh, a.statut_enr*/

with production as (
    select * from {{ ref('stg_production_enr') }}
),

consommation as (
    select * from {{ ref('stg_consommation') }}
),

autonomie as (
    select * from {{ ref('stg_autonomie') }}
),

installations as (
    select * from {{ ref('stg_installations_enr') }}
),

-- Nombre total d'installations par commune
installations_agg as (
    select
        code_insee,
        count(*)                                                    as nb_installations_totales,
        sum(puissance_installee_kw) / 1000                         as puissance_totale_installee_mw,
        sum(case when code_filiere = 'SOLAI' then 1 else 0 end)    as nb_sites_solaire,
        sum(case when code_filiere = 'EOLIE' then 1 else 0 end)    as nb_sites_eolien,
        min(date_mise_en_service)                                   as premiere_installation,
        max(date_mise_en_service)                                   as derniere_installation
    from installations
    where regime = 'En service'
    group by code_insee
)

select
    c.code_insee,
    c.nom_commune,
    -- Consommation
    c.conso_moy_periode_mwh,
    c.nb_habitants,
    c.conso_2017_mwh,
    c.conso_2018_mwh,
    c.conso_2019_mwh,
    c.conso_2020_mwh,
    c.conso_2021_mwh,
    c.conso_2022_mwh,
    c.conso_2023_mwh,
    c.conso_2024_mwh,
    c.evolution_conso_pct,
    -- Production
    coalesce(p.puissance_solaire_mw, 0)         as puissance_solaire_mw,
    coalesce(p.puissance_eolien_mw, 0)          as puissance_eolien_mw,
    coalesce(p.puissance_totale_mw, 0)          as puissance_totale_mw,
    coalesce(p.nb_installations_pv, 0)          as nb_installations_pv,
    coalesce(p.nb_installations_eol, 0)         as nb_installations_eol,
    coalesce(p.energie_solaire_mwh_an, 0)       as energie_solaire_mwh_an,
    coalesce(p.energie_eolien_mwh_an, 0)        as energie_eolien_mwh_an,
    coalesce(p.energie_totale_mwh_an, 0)        as energie_totale_mwh_an,
    coalesce(p.statut_enr, 'Vierge')            as statut_enr,
    -- Autonomie
    coalesce(a.taux_autonomie_pct, 0)           as taux_autonomie_pct,
    coalesce(a.surplus_mwh, 0)                  as surplus_mwh,
    coalesce(a.statut_autonomie, 'Déficitaire') as statut_autonomie,
    -- Installations détail
    coalesce(i.nb_installations_totales, 0)     as nb_installations_totales,
    coalesce(i.nb_sites_solaire, 0)             as nb_sites_solaire,
    coalesce(i.nb_sites_eolien, 0)              as nb_sites_eolien,
    i.premiere_installation,
    i.derniere_installation
from consommation c
left join production p      on c.code_insee = p.code_insee
left join autonomie a       on c.code_insee = a.code_insee
left join installations_agg i on c.code_insee = i.code_insee

