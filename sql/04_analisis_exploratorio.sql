/* 04 - Análisis exploratorio: crítica vs jugadores (2.947 juegos con Metacritic y 500+ reseñas) */

USE steam_analysis;
GO

-- 3a) Brecha promedio entre crítica y jugadores (Metacritic menos % positivo)
SELECT ROUND(AVG(metacritic_score - pct_positive), 1) AS brecha_promedio
FROM dbo.steam_games_clean
WHERE metacritic_score IS NOT NULL AND total_reviews >= 500;   -- -7.3: los jugadores puntúan más alto

-- 3b) Los 10 juegos donde la crítica puntuó MUCHO más alto que los jugadores
SELECT TOP 10 name, release_year, metacritic_score, pct_positive, total_reviews,
       metacritic_score - pct_positive AS brecha
FROM dbo.steam_games_clean
WHERE metacritic_score IS NOT NULL AND total_reviews >= 500
ORDER BY brecha DESC;

-- 3c) Los 10 juegos donde los jugadores puntuaron MUCHO más alto que la crítica
SELECT TOP 10 name, release_year, metacritic_score, pct_positive, total_reviews,
       metacritic_score - pct_positive AS brecha
FROM dbo.steam_games_clean
WHERE metacritic_score IS NOT NULL AND total_reviews >= 500
ORDER BY brecha ASC;

-- 4) Evolución por año de lanzamiento
SELECT release_year,
       COUNT(*)                               AS juegos,
       ROUND(AVG(metacritic_score * 1.0), 1)  AS prom_metacritic,
       ROUND(AVG(pct_positive), 1)            AS prom_pct_positivo
FROM dbo.steam_games_clean
WHERE metacritic_score IS NOT NULL AND total_reviews >= 500
GROUP BY release_year
ORDER BY release_year;

-- 5) Por género (un juego con varios géneros cuenta en cada uno)
SELECT TRIM(s.value)                          AS genero,
       COUNT(*)                               AS juegos,
       ROUND(AVG(c.metacritic_score * 1.0), 1) AS prom_metacritic,
       ROUND(AVG(c.pct_positive), 1)          AS prom_pct_positivo
FROM dbo.steam_games_clean c
CROSS APPLY STRING_SPLIT(c.genres, ',') s
WHERE c.metacritic_score IS NOT NULL AND c.total_reviews >= 500
GROUP BY TRIM(s.value)
HAVING COUNT(*) >= 30
ORDER BY prom_pct_positivo DESC;

-- 6) Los 15 juegos con más reseñas: ¿los más populares son los mejor valorados?
SELECT TOP 15 name, release_year, total_reviews, peak_ccu,
       metacritic_score, pct_positive
FROM dbo.steam_games_clean
WHERE metacritic_score IS NOT NULL AND total_reviews >= 500
ORDER BY total_reviews DESC;

-- 7) Correlación entre crítica y jugadores (Pearson, de -1 a 1)
WITH base AS (
    SELECT CAST(metacritic_score AS float) AS x, CAST(pct_positive AS float) AS y
    FROM dbo.steam_games_clean
    WHERE metacritic_score IS NOT NULL AND total_reviews >= 500
)
SELECT ROUND((AVG(x * y) - AVG(x) * AVG(y)) / (STDEVP(x) * STDEVP(y)), 2) AS correlacion
FROM base;   -- 0.55: van en la misma dirección, pero no coinciden del todo
