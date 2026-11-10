/* ==================================================================
   07 - ¿El GOTY es lo que eligen los jugadores?
   Compara a cada ganador contra los juegos que salieron en Steam
   el MISMO año. Así no le damos ventaja a los juegos viejos, que
   tuvieron más tiempo para juntar reseñas.

   - Popularidad = total de reseñas (lo más cercano a "cuánta gente
     lo jugó": Steam no publica ventas)
   - Aprobación  = % de reseñas positivas
   - Universo    = juegos con 500+ reseñas
   Requiere haber corrido 06 (tabla goty_ganadores).
   ================================================================== */

USE steam_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_goty_vs_su_anio AS
WITH universo AS (
    SELECT app_id, name, release_year, total_reviews, pct_positive
    FROM dbo.steam_games_clean
    WHERE total_reviews >= 500
),
popularidad AS (
    SELECT app_id, name, release_year, total_reviews, pct_positive,
           RANK()  OVER (PARTITION BY release_year ORDER BY total_reviews DESC) AS puesto_popularidad,
           COUNT(*) OVER (PARTITION BY release_year)                          AS juegos_del_anio
    FROM universo
),
-- Para comparar aprobación pedimos 5000+ reseñas: con pocas reseñas el % es muy volátil
aprobacion AS (
    SELECT app_id,
           RANK()  OVER (PARTITION BY release_year ORDER BY pct_positive DESC) AS puesto_aprobacion,
           COUNT(*) OVER (PARTITION BY release_year)                          AS juegos_5000_resenas
    FROM universo
    WHERE total_reviews >= 5000
),
mas_jugado AS (
    SELECT release_year, name AS mas_jugado_del_anio, total_reviews AS resenas_mas_jugado
    FROM popularidad
    WHERE puesto_popularidad = 1
)
SELECT g.goty_year,
       p.name,
       p.release_year                AS anio_en_steam,
       p.total_reviews,
       p.pct_positive,
       p.puesto_popularidad,
       p.juegos_del_anio,
       a.puesto_aprobacion,
       a.juegos_5000_resenas,
       m.mas_jugado_del_anio,
       m.resenas_mas_jugado
FROM dbo.goty_ganadores g
JOIN popularidad p ON p.app_id = g.app_id
LEFT JOIN aprobacion a ON a.app_id = g.app_id
LEFT JOIN mas_jugado m ON m.release_year = p.release_year;
GO

SELECT * FROM dbo.vw_goty_vs_su_anio ORDER BY goty_year;

-- ¿Cuántos ganadores quedaron en el top 10 de su año por popularidad?
SELECT SUM(CASE WHEN puesto_popularidad <= 10 THEN 1 ELSE 0 END) AS en_top10,
       SUM(CASE WHEN puesto_popularidad = 1  THEN 1 ELSE 0 END) AS fueron_el_mas_jugado,
       COUNT(*)                                                  AS ganadores_analizados
FROM dbo.vw_goty_vs_su_anio;

-- Para Power BI: todos los juegos de los años con GOTY, marcando al ganador.
-- Sirve para un gráfico de dispersión (reseñas vs % positivo) por año.
CREATE OR ALTER VIEW dbo.vw_goty_cohorte AS
SELECT g.goty_year,
       c.app_id, c.name, c.release_year, c.total_reviews, c.pct_positive, c.metacritic_score,
       CASE WHEN c.app_id = g.app_id THEN 'Ganador GOTY' ELSE 'Resto del año' END AS tipo,
       RANK() OVER (PARTITION BY g.goty_year ORDER BY c.total_reviews DESC) AS puesto_popularidad
FROM dbo.goty_ganadores g
JOIN dbo.steam_games_clean w ON w.app_id = g.app_id
JOIN dbo.steam_games_clean c ON c.release_year = w.release_year
WHERE c.total_reviews >= 500;
GO
