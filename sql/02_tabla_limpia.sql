/* ==================================================================
   02 - Limpieza: de steam_games_raw a steam_games_clean

   Qué se corrige y por qué:
   1. Tipos de dato: todo pasa de texto a número o fecha.
      Se usa TRY_CAST / TRY_PARSE: si un valor no se puede convertir
      queda NULL en lugar de romper la consulta.
   2. Fechas: vienen en inglés ("Aug 1, 2023"). TRY_PARSE con 'en-US'
      las lee bien aunque el SQL Server esté en español.
   3. Metacritic = 0 significa "sin puntaje", no un cero real.
      Se pasa a NULL para que no baje los promedios.
   4. Dueños estimados viene como rango ("20000 - 50000").
      Se separa en owners_min y owners_max.
   5. Columnas nuevas para el análisis:
      total_reviews = positivas + negativas
      pct_positive  = % de reseñas positivas (NULL si no tiene reseñas)
      release_year  = año de lanzamiento
   6. Textos: se sacan espacios sobrantes y los vacíos pasan a NULL.
   ================================================================== */

USE steam_analysis;
GO

DROP TABLE IF EXISTS dbo.steam_games_clean;
GO

WITH convertido AS (
    SELECT
        TRY_CAST(app_id AS int)                                  AS app_id,
        NULLIF(TRIM(name), '')                                   AS name,
        TRY_PARSE(CAST(release_date AS nvarchar(50)) AS date USING 'en-US')            AS release_date,
        TRY_CAST(TRIM(LEFT(estimated_owners,
                 NULLIF(CHARINDEX('-', estimated_owners), 0) - 1)) AS int)  AS owners_min,
        TRY_CAST(TRIM(SUBSTRING(estimated_owners,
                 NULLIF(CHARINDEX('-', estimated_owners), 0) + 1, 50)) AS int) AS owners_max,
        TRY_CAST(peak_ccu AS int)                                AS peak_ccu,
        TRY_CAST(price AS decimal(10,2))                         AS price,
        NULLIF(TRY_CAST(metacritic_score AS int), 0)             AS metacritic_score,
        TRY_CAST(positive_reviews AS int)                        AS positive_reviews,
        TRY_CAST(negative_reviews AS int)                        AS negative_reviews,
        TRY_CAST(recommendations AS int)                         AS recommendations,
        TRY_CAST(avg_playtime_minutes AS int)                    AS avg_playtime_minutes,
        TRY_CAST(median_playtime_minutes AS int)                 AS median_playtime_minutes,
        NULLIF(TRIM(developers), '')                             AS developers,
        NULLIF(TRIM(genres), '')                                 AS genres
    FROM dbo.steam_games_raw
)
SELECT
    app_id,
    name,
    release_date,
    YEAR(release_date)                          AS release_year,
    owners_min,
    owners_max,
    peak_ccu,
    price,
    metacritic_score,
    positive_reviews,
    negative_reviews,
    positive_reviews + negative_reviews         AS total_reviews,
    CAST(ROUND(100.0 * positive_reviews
         / NULLIF(positive_reviews + negative_reviews, 0), 1)
         AS decimal(5,1))                       AS pct_positive,
    recommendations,
    avg_playtime_minutes,
    median_playtime_minutes,
    developers,
    genres
INTO dbo.steam_games_clean
FROM convertido;
GO

ALTER TABLE dbo.steam_games_clean ALTER COLUMN app_id int NOT NULL;
ALTER TABLE dbo.steam_games_clean ADD CONSTRAINT pk_steam_games_clean PRIMARY KEY (app_id);
GO

-- Control: ¿se perdió alguna fila o quedó algún valor sin convertir?
SELECT
    (SELECT COUNT(*) FROM dbo.steam_games_raw)                    AS filas_raw,
    COUNT(*)                                                      AS filas_clean,
    SUM(CASE WHEN release_date IS NULL THEN 1 ELSE 0 END)         AS fechas_sin_convertir,
    SUM(CASE WHEN total_reviews IS NULL THEN 1 ELSE 0 END)        AS resenas_sin_convertir
FROM dbo.steam_games_clean;
-- Esperado: 125855 | 125855 | 0 | 0
