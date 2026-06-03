with features as (
    select * from {{ ref('mart_features_communes') }}
),

stats as (
    select
        -- Percentiles P5/P95 pour éviter l'écrasement par les extrêmes
        percentile_cont(production_kwh_kwc_an,     0.05) over() as p05_pvgis,
        percentile_cont(production_kwh_kwc_an,     0.95) over() as p95_pvgis,
        percentile_cont(irradiation_kwh_m2_an,     0.05) over() as p05_irrad,
        percentile_cont(irradiation_kwh_m2_an,     0.95) over() as p95_irrad,
        percentile_cont(wind_speed_moy_ms,         0.05) over() as p05_vent,
        percentile_cont(wind_speed_moy_ms,         0.95) over() as p95_vent,
        percentile_cont(productible_eolien_mwh_an, 0.05) over() as p05_productible,
        percentile_cont(productible_eolien_mwh_an, 0.95) over() as p95_productible,
        percentile_cont(pente_moy_deg,             0.05) over() as p05_pente,
        percentile_cont(pente_moy_deg,             0.95) over() as p95_pente
    from features
    limit 1
),

normalized as (
    select
        f.*,

        -- PVGIS normalisé P5-P95
        least(1.0, greatest(0.0,
            safe_divide(
                f.production_kwh_kwc_an - s.p05_pvgis,
                s.p95_pvgis - s.p05_pvgis
            )
        ))                                                      as n_pvgis,

        -- Irradiation normalisée P5-P95
        least(1.0, greatest(0.0,
            safe_divide(
                f.irradiation_kwh_m2_an - s.p05_irrad,
                s.p95_irrad - s.p05_irrad
            )
        ))                                                      as n_irrad,

        -- Surface solaire (log pour réduire l'effet des grandes surfaces)
        least(1.0, greatest(0.0,
            safe_divide(
                ln(f.surface_solaire_ha + 1),
                ln(10000)
            )
        ))                                                      as n_surf_sol,

        -- Pente inversée P5-P95
        least(1.0, greatest(0.0,
            1 - safe_divide(
                f.pente_moy_deg - s.p05_pente,
                s.p95_pente - s.p05_pente
            )
        ))                                                      as n_pente_inv,

        -- Vent normalisé P5-P95
        least(1.0, greatest(0.0,
            safe_divide(
                f.wind_speed_moy_ms - s.p05_vent,
                s.p95_vent - s.p05_vent
            )
        ))                                                      as n_vent,

        -- Productible éolien normalisé P5-P95
        least(1.0, greatest(0.0,
            safe_divide(
                f.productible_eolien_mwh_an - s.p05_productible,
                s.p95_productible - s.p05_productible
            )
        ))                                                      as n_productible,

        -- Surface éolien (log)
        least(1.0, greatest(0.0,
            safe_divide(
                ln(f.surface_eolien_ha + 1),
                ln(50000)
            )
        ))                                                      as n_surf_eol,

        -- Raccordement
        case f.score_raccordement
            when 'Très favorable' then 1.0
            when 'Favorable'      then 0.75
            when 'Modéré'         then 0.40
            when 'Difficile'      then 0.10
            else 0.5
        end                                                     as n_raccordement,

        -- Zones protégées (inversé)
        case
            when f.pct_territoire_protege >= 75 then 0.0
            when f.pct_territoire_protege >= 50 then 0.25
            when f.pct_territoire_protege >= 25 then 0.50
            when f.pct_territoire_protege >= 10 then 0.75
            else 1.0
        end                                                     as n_zones_inv,

        -- Fiabilité vent
        case f.fiabilite_vent
            when 'Très fiable'       then 1.0
            when 'Fiable'            then 0.75
            when 'Modérément fiable' then 0.45
            when 'Variable'          then 0.20
            else 0.10
        end                                                     as n_fiabilite_vent

    from features f
    cross join stats s
),

scored as (
    select
        *,

        -- Score Solaire (0-100)
        round((
            0.35 * coalesce(n_pvgis,       0) +
            0.30 * coalesce(n_irrad,        0) +
            0.15 * coalesce(n_zones_inv,    0) +
            0.10 * coalesce(n_pente_inv,    0) +
            0.05 * coalesce(n_surf_sol,     0) +
            0.05 * coalesce(n_raccordement, 0)
        ) * 100, 1)                                             as score_solaire,

        -- Score Éolien (0-100)
        round((
            0.40 * coalesce(n_vent,             0) +
            0.25 * coalesce(n_productible,      0) +
            0.15 * coalesce(n_fiabilite_vent,   0) +
            0.10 * coalesce(n_zones_inv,        0) +
            0.05 * coalesce(n_surf_eol,         0) +
            0.05 * coalesce(n_raccordement,     0)
        ) * 100, 1)                                             as score_eolien

    from normalized
)

select
    code_insee,
    nom_commune,
    latitude,
    longitude,
    code_departement,
    score_solaire,
    score_eolien,
    greatest(score_solaire, score_eolien)                       as score_global,

    case
        when score_solaire >= 60 and score_eolien >= 60 then 'Solaire + Éolien'
        when score_solaire >= score_eolien              then 'Solaire'
        else                                                 'Éolien'
    end                                                         as technologie_recommandee,

    case
        when greatest(score_solaire, score_eolien) >= 70 then 'Top potentiel'
        when greatest(score_solaire, score_eolien) >= 50 then 'Bon potentiel'
        when greatest(score_solaire, score_eolien) >= 30 then 'Potentiel modéré'
        else                                                  'Faible potentiel'
    end                                                         as classe_score,

    nb_habitants,
    conso_moy_periode_mwh,
    production_kwh_kwc_an,
    irradiation_kwh_m2_an,
    wind_speed_moy_ms,
    productible_eolien_mwh_an,
    surface_solaire_ha,
    surface_eolien_ha,
    pct_territoire_protege,
    pente_moy_deg,
    altitude_moy_m,
    score_raccordement,
    taux_autonomie_pct,
    statut_enr,
    statut_autonomie,
    puissance_totale_mw,
    energie_totale_mwh_an,
    classe_solaire,
    classe_vent,
    viable_solaire,
    viable_eolien,
    fiabilite_vent,

    round(n_pvgis * 100, 1)             as score_composante_pvgis,
    round(n_irrad * 100, 1)             as score_composante_irradiation,
    round(n_surf_sol * 100, 1)          as score_composante_surface_sol,
    round(n_pente_inv * 100, 1)         as score_composante_pente,
    round(n_vent * 100, 1)              as score_composante_vent,
    round(n_productible * 100, 1)       as score_composante_productible,
    round(n_surf_eol * 100, 1)          as score_composante_surface_eol,
    round(n_zones_inv * 100, 1)         as score_composante_zones,
    round(n_raccordement * 100, 1)      as score_composante_raccordement,
    round(n_fiabilite_vent * 100, 1)    as score_composante_fiabilite_vent

from scored