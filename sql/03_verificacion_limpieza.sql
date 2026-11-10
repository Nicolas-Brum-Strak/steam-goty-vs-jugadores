/* 03 - Verificación de la tabla limpia: los números esperados están al lado de cada consulta */

USE steam_analysis;
GO

SELECT COUNT(*) AS total_filas FROM dbo.steam_games_clean;              -- 125855

SELECT COUNT(metacritic_score) AS con_metacritic FROM dbo.steam_games_clean;      -- 4258

SELECT COUNT(*) AS con_500_resenas FROM dbo.steam_games_clean WHERE total_reviews >= 500;   -- 10507

SELECT name, release_date, release_year, owners_min, owners_max,
       metacritic_score, total_reviews, pct_positive
FROM dbo.steam_games_clean
WHERE name = 'The Witcher 3: Wild Hunt';   -- 2015, Metacritic 93, 835349 reseñas, 96.1% positivo
