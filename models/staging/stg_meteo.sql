with source as (
    select * from {{ source('data_meteo', 'meteo_rendement_commune') }}
),

converted as (
    select
        LPAD(cast(code_insee as string), 5, '0')            as code_insee,
        commune,
        cast(latitude as float64)                           as latitude,
        cast(longitude as float64)                          as longitude,
        cast(radiation_moy_wh_m2_jour as float64)           as radiation_moy_wh_m2_jour,
        cast(radiation_total_wh_m2 as float64)              as radiation_total_wh_m2,
        cast(sunshine_moy_h_jour as float64)                as sunshine_moy_h_jour,
        cast(sunshine_total_h as float64)                   as sunshine_total_h,
        cast(cloud_cover_moy_pct as float64)                as cloud_cover_moy_pct,
        cast(rain_moy_mm_jour as float64)                   as rain_moy_mm_jour,
        cast(nb_jours as int64)                             as nb_jours,
        cast(production_kwh_kwc_an as float64)              as production_kwh_kwc_an,
        cast(irradiation_kwh_m2_an as float64)              as irradiation_kwh_m2_an,
        cast(performance_ratio_pct as float64)              as performance_ratio_pct,
        classe_solaire,
        cast(viable_solaire as bool)                        as viable_solaire,

        -- ── CORRECTION VENT : km/h → m/s (÷3.6) puis 10m → 100m (×1.38 Hellmann α=0.14) ──
        round(cast(wind_speed_moy_ms as float64) / 3.6 * 1.38, 2)   as wind_speed_moy_ms,
        round(cast(wind_speed_max_ms as float64) / 3.6 * 1.38, 2)   as wind_speed_max_ms,
        round(cast(wind_p50 as float64) / 3.6 * 1.38, 2)            as wind_p50,
        round(cast(wind_p75 as float64) / 3.6 * 1.38, 2)            as wind_p75,
        round(cast(wind_p90 as float64) / 3.6 * 1.38, 2)            as wind_p90
    from source
),

final as (
    select
        *,

        -- ── FACTEUR DE CHARGE ÉOLIEN — courbe réaliste (calibrée RTE ~21-25%) ──
        round(
            case
                when wind_speed_moy_ms < 3   then 0.0
                when wind_speed_moy_ms < 4   then 0.08
                when wind_speed_moy_ms < 5   then 0.15
                when wind_speed_moy_ms < 6   then 0.22
                when wind_speed_moy_ms < 7   then 0.30
                when wind_speed_moy_ms < 8   then 0.37
                when wind_speed_moy_ms < 9   then 0.42
                else 0.45
            end * 100, 1
        )                                                   as facteur_charge_eolien_pct,

        -- ── PRODUCTIBLE ÉOLIEN — 2 MW × 8760h × facteur charge ──
        round(
            2 * 8760 * (
                case
                    when wind_speed_moy_ms < 3   then 0.0
                    when wind_speed_moy_ms < 4   then 0.08
                    when wind_speed_moy_ms < 5   then 0.15
                    when wind_speed_moy_ms < 6   then 0.22
                    when wind_speed_moy_ms < 7   then 0.30
                    when wind_speed_moy_ms < 8   then 0.37
                    when wind_speed_moy_ms < 9   then 0.42
                    else 0.45
                end
            ), 1
        )                                                   as productible_eolien_mwh_an,

        -- ── CLASSE VENT (recalculée sur vent 100m corrigé) ──
        case
            when wind_speed_moy_ms < 4   then 'Faible 3-4 m/s'
            when wind_speed_moy_ms < 5.5 then 'Modéré 4-5.5 m/s'
            when wind_speed_moy_ms < 7   then 'Bon 5.5-7 m/s'
            else 'Excellent ≥ 7 m/s'
        end                                                 as classe_vent,

        -- ── VIABLE ÉOLIEN (≥ 5 m/s à 100m) ──
        wind_speed_moy_ms >= 5                              as viable_eolien,

        -- ── FIABILITÉ VENT (basée sur régularité p50/p90) ──
        case
            when wind_p50 >= 6   then 'Très fiable'
            when wind_p50 >= 5   then 'Fiable'
            when wind_p50 >= 4   then 'Modérément fiable'
            else 'Variable'
        end                                                 as fiabilite_vent

    from converted
)

select * from final