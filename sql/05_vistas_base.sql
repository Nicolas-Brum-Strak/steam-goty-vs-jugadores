/* 05 - Vistas base para Power BI */

USE steam_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_analisis_base AS
SELECT app_id, name, release_year, owners_min, owners_max, peak_ccu, price,
       metacritic_score, total_reviews, pct_positive,
       metacritic_score - pct_positive AS brecha,
       CASE
           WHEN metacritic_score < 50 THEN '1) menos de 50'
           WHEN metacritic_score < 60 THEN '2) 50-59'
           WHEN metacritic_score < 70 THEN '3) 60-69'
           WHEN metacritic_score < 80 THEN '4) 70-79'
           WHEN metacritic_score < 90 THEN '5) 80-89'
           ELSE '6) 90 o más'
       END AS banda_metacritic
FROM dbo.steam_games_clean
WHERE metacritic_score IS NOT NULL AND total_reviews >= 500;
GO

CREATE OR ALTER VIEW dbo.vw_juego_genero AS
SELECT b.app_id, b.name, b.release_year, b.metacritic_score,
       b.pct_positive, b.total_reviews, TRIM(s.value) AS genero
FROM dbo.vw_analisis_base b
JOIN dbo.steam_games_clean c ON c.app_id = b.app_id
CROSS APPLY STRING_SPLIT(c.genres, ',') s;
GO

SELECT COUNT(*) AS filas FROM dbo.vw_analisis_base;  -- debe dar 2947