/* ==================================================================
   06 - Ganadores del Game of the Year (The Game Awards)
   En qué percentil queda cada ganador frente a todos los juegos
   con Metacritic y 500+ reseñas (100 = el mejor).
   ================================================================== */

USE steam_analysis;
GO

DROP TABLE IF EXISTS dbo.goty_ganadores;
GO

CREATE TABLE dbo.goty_ganadores (
    goty_year int PRIMARY KEY,
    app_id    int NOT NULL,
    nota      varchar(100)
);

INSERT INTO dbo.goty_ganadores (goty_year, app_id, nota) VALUES
    (2014, 1222690, 'Dragon Age: Inquisition - llegó a Steam en 2020'),
    (2015,  292030, 'The Witcher 3: Wild Hunt'),
    (2018, 1593500, 'God of War - llegó a Steam en 2022'),
    (2019,  814380, 'Sekiro: Shadows Die Twice'),
    (2020, 2531310, 'The Last of Us Part II - remaster, llegó a Steam en 2025'),
    (2021, 1426210, 'It Takes Two'),
    (2022, 1245620, 'Elden Ring'),
    (2023, 1086940, 'Baldur''s Gate 3'),
    (2025, 1903340, 'Clair Obscur: Expedition 33');
-- Sin datos en Steam: 2016 Overwatch, 2017 Zelda: Breath of the Wild, 2024 Astro Bot
GO

-- Universo: juegos con 500+ reseñas. La crítica solo se rankea entre los que tienen Metacritic.
-- (The Last of Us Part II no tiene Metacritic en Steam, por eso su percentil de crítica queda vacío.)
CREATE OR ALTER VIEW dbo.vw_goty AS
WITH universo AS (
    SELECT app_id, name, metacritic_score, pct_positive, total_reviews,
           PERCENT_RANK() OVER (ORDER BY pct_positive)  AS p_jugadores,
           PERCENT_RANK() OVER (ORDER BY total_reviews) AS p_popularidad
    FROM dbo.steam_games_clean
    WHERE total_reviews >= 500
),
critica AS (
    SELECT app_id,
           PERCENT_RANK() OVER (ORDER BY metacritic_score) AS p_critica
    FROM dbo.steam_games_clean
    WHERE metacritic_score IS NOT NULL AND total_reviews >= 500
)
SELECT g.goty_year, u.name, u.metacritic_score, u.pct_positive, u.total_reviews,
       CAST(ROUND(100 * c.p_critica, 0) AS int)      AS percentil_critica,
       CAST(ROUND(100 * u.p_jugadores, 0) AS int)    AS percentil_jugadores,
       CAST(ROUND(100 * u.p_popularidad, 0) AS int)  AS percentil_popularidad
FROM dbo.goty_ganadores g
JOIN universo u     ON u.app_id = g.app_id
LEFT JOIN critica c ON c.app_id = g.app_id;
GO

SELECT * FROM dbo.vw_goty ORDER BY goty_year;
