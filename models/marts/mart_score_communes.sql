with features as (
    select * from {{ ref('mart_features_communes') }}
),

stats as (
    select
        percentile_cont(production_kwh_kwc_an,     0.05) over() as p05_pvgis,
        percentile_cont(production_kwh_kwc_an,     0.95) over() as p95_pvgis,
        percentile_cont(irradiation_kwh_m2_an,     0.05) over() as p05_irrad,
        percentile_cont(irradiation_kwh_m2_an,     0.95) over() as p95_irrad,
        percentile_cont(wind_speed_moy_ms,         0.05) over() as p05_vent,
        percentile_cont(wind_speed_moy_ms,         0.95) over() as p95_vent,
        percentile_cont(productible_eolien_mwh_an, 0.25) over() as p25_productible,
        percentile_cont(productible_eolien_mwh_an, 0.75) over() as p75_productible,
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

        -- Surface solaire (log)
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

        -- Productible éolien normalisé P25-P75
        least(1.0, greatest(0.0,
            safe_divide(
                f.productible_eolien_mwh_an - s.p25_productible,
                s.p75_productible - s.p25_productible
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
            when 'Très favorable' then 0.70
            when 'Favorable'      then 0.50
            when 'Modéré'         then 0.25
            when 'Difficile'      then 0.05
            else 0.30
        end                                                     as n_raccordement,

        -- Zones protégées
        case
            when f.pct_territoire_protege >= 75 then 0.0
            when f.pct_territoire_protege >= 50 then 0.15
            when f.pct_territoire_protege >= 25 then 0.40
            when f.pct_territoire_protege >= 10 then 0.65
            when f.pct_territoire_protege >= 5  then 0.85
            else 1.0
        end                                                     as n_zones_inv,

        -- Fiabilité vent
        case f.fiabilite_vent
            when 'Très fiable'       then 0.80
            when 'Fiable'            then 0.55
            when 'Modérément fiable' then 0.30
            when 'Variable'          then 0.10
            else 0.05
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
),

final as (
    select
        code_insee,
        nom_commune,
        latitude,
        longitude,
        code_departement,
        score_solaire,
        score_eolien,
        greatest(score_solaire, score_eolien)                   as score_global,

        -- Recommandation
        case
            when score_solaire >= 50 and score_eolien >= 50 then 'Solaire + Éolien'
            when score_solaire >= score_eolien              then 'Solaire'
            else                                                 'Éolien'
        end                                                     as technologie_recommandee,

        -- Classe
        case
            when greatest(score_solaire, score_eolien) >= 60 then 'Top potentiel'
            when greatest(score_solaire, score_eolien) >= 45 then 'Bon potentiel'
            when greatest(score_solaire, score_eolien) >= 30 then 'Potentiel modéré'
            else                                                  'Faible potentiel'
        end                                                     as classe_score,

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
        classe_pente_dominante,
        exposition_dominante,
        has_natura2000,
        has_znieff,
        has_parc_national,
        has_pnr,
        has_reserve_naturelle,

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
)

select * from final
