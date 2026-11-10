USE steam_analysis;
GO

-- 1) Tiene que dar 125855
SELECT COUNT(*) AS total_filas FROM dbo.steam_games_raw;

-- 2) Mirar las primeras filas
SELECT TOP 10 * FROM dbo.steam_games_raw;

-- 3) Comprobar que las columnas no están corridas
SELECT name, metacritic_score, positive_reviews, negative_reviews
FROM dbo.steam_games_raw
WHERE name = 'The Witcher 3: Wild Hunt';

-- 4) Comprobar que los símbolos se ven bien
SELECT name FROM dbo.steam_games_raw
WHERE name LIKE 'Dragon Age%Inquisition';

-- 5) Comprobar que no hay juegos repetidos (no debería devolver filas)
SELECT app_id, COUNT(*) AS veces
FROM dbo.steam_games_raw
GROUP BY app_id
HAVING COUNT(*) > 1;