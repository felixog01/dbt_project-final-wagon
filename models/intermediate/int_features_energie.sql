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
installations_agg as (
    select
        code_insee,
        count(*)                                                    as nb_installations_totales,
        sum(puissance_installee_kw) / 1000                          as puissance_totale_installee_mw,
        sum(case when code_filiere = 'SOLAI' then 1 else 0 end)     as nb_sites_solaire,
        sum(case when code_filiere = 'EOLIE' then 1 else 0 end)     as nb_sites_eolien,
        min(date_mise_en_service)                                   as premiere_installation,
        max(date_mise_en_service)                                   as derniere_installation
    from installations
    where regime = 'En service'
    group by code_insee
)
select
    LPAD(c.code_insee, 5, '0')                          as code_insee,
    c.nom_commune,

    -- Consommation
    c.conso_moy_periode_mwh,
    coalesce(c.nb_habitants, 0)                         as nb_habitants,
    coalesce(c.conso_2017_mwh, c.conso_moy_periode_mwh) as conso_2017_mwh,
    coalesce(c.conso_2018_mwh, c.conso_moy_periode_mwh) as conso_2018_mwh,
    coalesce(c.conso_2019_mwh, c.conso_moy_periode_mwh) as conso_2019_mwh,
    coalesce(c.conso_2020_mwh, c.conso_moy_periode_mwh) as conso_2020_mwh,
    coalesce(c.conso_2021_mwh, c.conso_moy_periode_mwh) as conso_2021_mwh,
    coalesce(c.conso_2022_mwh, c.conso_moy_periode_mwh) as conso_2022_mwh,
    coalesce(c.conso_2023_mwh, c.conso_moy_periode_mwh) as conso_2023_mwh,
    coalesce(c.conso_2024_mwh, c.conso_moy_periode_mwh) as conso_2024_mwh,

    -- Évolution conso : gérer inf et caper à ±200%
    case
        when c.evolution_conso_pct is null then 0
        when is_inf(c.evolution_conso_pct) then 0
        else least(200, greatest(-100, c.evolution_conso_pct))
    end                                                 as evolution_conso_pct,

    -- Production
    coalesce(p.puissance_solaire_mw, 0)                 as puissance_solaire_mw,
    coalesce(p.puissance_eolien_mw, 0)                  as puissance_eolien_mw,
    coalesce(p.puissance_totale_mw, 0)                  as puissance_totale_mw,
    coalesce(p.nb_installations_pv, 0)                  as nb_installations_pv,
    coalesce(p.nb_installations_eol, 0)                 as nb_installations_eol,

    -- Énergie : forcer >= 0 (corrige le -2)
    greatest(0, coalesce(p.energie_solaire_mwh_an, 0))  as energie_solaire_mwh_an,
    greatest(0, coalesce(p.energie_eolien_mwh_an, 0))   as energie_eolien_mwh_an,
    greatest(0, coalesce(p.energie_totale_mwh_an, 0))   as energie_totale_mwh_an,
    coalesce(p.statut_enr, 'Vierge')                    as statut_enr,

    -- Autonomie : gérer inf et caper à 200%
    case
        when a.taux_autonomie_pct is null then 0
        when is_inf(a.taux_autonomie_pct) then 0
        else least(200, greatest(0, a.taux_autonomie_pct))
    end                                                 as taux_autonomie_pct,
    coalesce(a.surplus_mwh, 0)                          as surplus_mwh,
    coalesce(a.statut_autonomie, 'Déficitaire')         as statut_autonomie,

    -- Installations détail
    coalesce(i.nb_installations_totales, 0)             as nb_installations_totales,
    coalesce(i.nb_sites_solaire, 0)                     as nb_sites_solaire,
    coalesce(i.nb_sites_eolien, 0)                      as nb_sites_eolien,
    i.premiere_installation,
    i.derniere_installation

from consommation c
left join production p        on LPAD(c.code_insee, 5, '0') = LPAD(p.code_insee, 5, '0')
left join autonomie a         on LPAD(c.code_insee, 5, '0') = LPAD(a.code_insee, 5, '0')
left join installations_agg i on LPAD(c.code_insee, 5, '0') = LPAD(i.code_insee, 5, '0')