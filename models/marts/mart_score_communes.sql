with features as (
    select * from {{ ref('mart_features_communes') }}
),

-- ── NORMALISATION MIN-MAX ─────────────────────────────────────────────────────
stats as (
    select
        -- Solaire
        min(production_kwh_kwc_an)      as min_pvgis,
        max(production_kwh_kwc_an)      as max_pvgis,
        min(irradiation_kwh_m2_an)      as min_irrad,
        max(irradiation_kwh_m2_an)      as max_irrad,
        min(surface_solaire_ha)         as min_surf_sol,
        max(surface_solaire_ha)         as max_surf_sol,
        min(pente_moy_deg)              as min_pente,
        max(pente_moy_deg)              as max_pente,
        -- Eolien
        min(wind_speed_moy_ms)          as min_vent,
        max(wind_speed_moy_ms)          as max_vent,
        min(productible_eolien_mwh_an)  as min_productible,
        max(productible_eolien_mwh_an)  as max_productible,
        min(surface_eolien_ha)          as min_surf_eol,
        max(surface_eolien_ha)          as max_surf_eol
    from features
),

normalized as (
    select
        f.*,

        -- Solaire
        safe_divide(
            f.production_kwh_kwc_an - s.min_pvgis,
            s.max_pvgis - s.min_pvgis
        )                                                       as n_pvgis,

        safe_divide(
            f.irradiation_kwh_m2_an - s.min_irrad,
            s.max_irrad - s.min_irrad
        )                                                       as n_irrad,

        safe_divide(
            f.surface_solaire_ha - s.min_surf_sol,
            s.max_surf_sol - s.min_surf_sol
        )                                                       as n_surf_sol,

        1 - safe_divide(
            f.pente_moy_deg - s.min_pente,
            s.max_pente - s.min_pente
        )                                                       as n_pente_inv,

        -- Eolien
        safe_divide(
            f.wind_speed_moy_ms - s.min_vent,
            s.max_vent - s.min_vent
        )                                                       as n_vent,

        safe_divide(
            f.productible_eolien_mwh_an - s.min_productible,
            s.max_productible - s.min_productible
        )                                                       as n_productible,

        safe_divide(
            f.surface_eolien_ha - s.min_surf_eol,
            s.max_surf_eol - s.min_surf_eol
        )                                                       as n_surf_eol,

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
            when 'Très fiable'          then 1.0
            when 'Fiable'               then 0.75
            when 'Modérément fiable'    then 0.45
            when 'Variable'             then 0.20
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
            0.25 * coalesce(n_pvgis,       0) +
            0.20 * coalesce(n_irrad,        0) +
            0.20 * coalesce(n_surf_sol,     0) +
            0.15 * coalesce(n_zones_inv,    0) +
            0.10 * coalesce(n_pente_inv,    0) +
            0.10 * coalesce(n_raccordement, 0)
        ) * 100, 1)                                             as score_solaire,

        -- Score Éolien (0-100)
        round((
            0.25 * coalesce(n_vent,             0) +
            0.20 * coalesce(n_productible,      0) +
            0.15 * coalesce(n_fiabilite_vent,   0) +
            0.15 * coalesce(n_surf_eol,         0) +
            0.15 * coalesce(n_zones_inv,        0) +
            0.10 * coalesce(n_raccordement,     0)
        ) * 100, 1)                                             as score_eolien

    from normalized
)

select
    -- Identifiants
    code_insee,
    nom_commune,
    latitude,
    longitude,
    code_departement,

    -- Scores
    score_solaire,
    score_eolien,
    greatest(score_solaire, score_eolien)                       as score_global,

    -- Recommandation
    case
        when score_solaire >= 60 and score_eolien >= 60 then 'Solaire + Éolien'
        when score_solaire >= score_eolien              then 'Solaire'
        else                                                 'Éolien'
    end                                                         as technologie_recommandee,

    -- Classe
    case
        when greatest(score_solaire, score_eolien) >= 70 then 'Top potentiel'
        when greatest(score_solaire, score_eolien) >= 50 then 'Bon potentiel'
        when greatest(score_solaire, score_eolien) >= 30 then 'Potentiel modéré'
        else                                                  'Faible potentiel'
    end                                                         as classe_score,

    -- Features clés dashboard
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

    -- Scores détaillés
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