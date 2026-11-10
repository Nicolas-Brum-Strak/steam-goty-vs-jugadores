/* ==================================================================
   08 - En general, ¿mejor crítica significa más jugadores?
   Agrupa los 2.947 juegos por banda de Metacritic y mira cuánta
   gente los juega (reseñas) y cuánto les gustan (% positivo).
   Se usa la MEDIANA de reseñas y no el promedio: unos pocos
   juegos gigantes (Dota 2, GTA V) inflarían cualquier promedio.
   Requiere haber corrido 05 (vista vw_analisis_base).
   ================================================================== */

USE steam_analysis;
GO

CREATE OR ALTER VIEW dbo.vw_critica_vs_popularidad AS
WITH mediana AS (
    SELECT DISTINCT banda_metacritic,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_reviews)
               OVER (PARTITION BY banda_metacritic) AS mediana_resenas
    FROM dbo.vw_analisis_base
)
SELECT b.banda_metacritic,
       COUNT(*)                                                    AS juegos,
       CAST(MAX(m.mediana_resenas) AS int)                         AS mediana_resenas,
       ROUND(AVG(b.pct_positive), 1)                               AS prom_pct_positivo,
       CAST(ROUND(100.0 * SUM(CASE WHEN b.total_reviews >= 100000 THEN 1 ELSE 0 END)
                  / COUNT(*), 1) AS decimal(5,1))                  AS pct_con_100k_resenas
FROM dbo.vw_analisis_base b
JOIN mediana m ON m.banda_metacritic = b.banda_metacritic
GROUP BY b.banda_metacritic;
GO

SELECT * FROM dbo.vw_critica_vs_popularidad ORDER BY banda_metacritic;
/* Resultado esperado:
   banda            juegos  mediana_resenas  prom_pct_positivo  pct_con_100k_resenas
   1) menos de 50       34            2251               50.8                   0.0
   2) 50-59            120            1554               68.8                   0.8
   3) 60-69            442            1895               76.0                   0.9
   4) 70-79           1224            2965               82.7                   1.8
   5) 80-89           1014            6535               88.8                   9.0
   6) 90 o más         113           28579               91.5                  26.5
*/
