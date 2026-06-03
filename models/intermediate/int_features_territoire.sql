-- int_features_territoire.sql

SELECT 
    MIN(altitude_m) AS min_altitude,
    MAX(altitude_m) AS max_altitude,
    AVG(altitude_m) AS avg_altitude,
    MIN(pente_deg) AS min_pente,
    MAX(pente_deg) AS max_pente,
    AVG(pente_deg) AS avg_pente,
    -- MIN(classe_pente) AS min_classe_pente,
    -- MAX(classe_pente) AS max_classe_pente,
    -- AVG(classe_pente) AS avg_classe_pente,
    -- MIN(expostition) AS min_exposition,
    -- MAX(expostition) AS max_exposition,
    -- AVG(expostition) AS avg_exposition,    
FROM {{ ref('stg_relief') }}
