# ¿El reconocimiento de la crítica predice lo que eligen los jugadores?

**Caso de estudio: los ganadores del Game of the Year en Steam.**

Los estudios de videojuegos invierten mucho en conseguir buenas críticas y premios. Este proyecto analiza, con **SQL Server** y 125.855 juegos de Steam, si eso se traduce en lo que realmente importa: que la gente juegue el juego y le guste.

## Respuesta corta

**La crítica anticipa la popularidad, pero no la garantiza, y no predice cuál va a ser el favorito de los jugadores.**

- Un juego con 90+ en Metacritic tiene una mediana de **28.579 reseñas**, casi **10 veces más** que uno de 70–79. Pero solo **1 de cada 4** juegos con 90+ supera las 100.000 reseñas.
- **7 de 9** ganadores del GOTY quedaron en el top 10 de juegos más jugados de su año, pero solo **2** fueron el más jugado (Elden Ring y Baldur's Gate 3).
- **Ninguno** fue el mejor valorado por los jugadores de su año. Los favoritos suelen ser indies como *Vampire Survivors*, *A Short Hike* o *Schedule I*.

## Preguntas y resultados

### 1. ¿Los ganadores del GOTY están entre los más jugados de su año?

Cada ganador se compara con los juegos que salieron en Steam ese mismo año, para no darles ventaja a los juegos viejos, que tuvieron más tiempo para juntar reseñas.

| GOTY | Juego | Puesto en reseñas (en su año) | % positivo | El más jugado de ese año |
|---|---|---|---|---|
| 2014 | Dragon Age: Inquisition ¹ | #102 de 944 | 75,4% | Apex Legends |
| 2015 | The Witcher 3 | #3 de 676 | 96,1% | GTA V |
| 2018 | God of War ¹ | #8 de 787 | 96,0% | Elden Ring |
| 2019 | Sekiro | #3 de 818 | 95,3% | Red Dead Redemption 2 |
| 2020 | The Last of Us Part II ¹ | #20 de 429 | 90,5% | Monster Hunter Wilds |
| 2021 | It Takes Two | #6 de 869 | 95,3% | Valheim |
| 2022 | Elden Ring | **#1** de 787 | 92,9% | **Elden Ring** |
| 2023 | Baldur's Gate 3 | **#1** de 858 | 96,8% | **Baldur's Gate 3** |
| 2025 | Clair Obscur: Expedition 33 | #5 de 429 | 95,7% | Monster Hunter Wilds |

¹ Llegó tarde a Steam (Dragon Age en 2020, God of War en 2022, The Last of Us Part II como remaster en 2025), así que se compara con los juegos del año en que llegó.

### 2. ¿Los jugadores los valoran tanto como la crítica?

La mayoría tiene entre 90% y 97% de reseñas positivas: 6 de 9 están en el 11% mejor valorado de Steam. Pero hay excepciones:

- **Dragon Age: Inquisition** quedó en el **cuarto inferior** de aprobación de todo Steam (percentil 24). Es el caso más claro de crítica y jugadores en desacuerdo.
- **Elden Ring** fue el más jugado de 2022, pero en aprobación quedó en el puesto 53 de 191 juegos grandes de ese año.

### 3. En general, ¿mejor crítica significa más jugadores?

Sobre 2.947 juegos con puntaje Metacritic y 500+ reseñas:

| Metacritic | Juegos | Mediana de reseñas | % positivo promedio | Superan 100.000 reseñas |
|---|---|---|---|---|
| Menos de 50 | 34 | 2.251 | 50,8% | 0% |
| 50–59 | 120 | 1.554 | 68,8% | 0,8% |
| 60–69 | 442 | 1.895 | 76,0% | 0,9% |
| 70–79 | 1.224 | 2.965 | 82,7% | 1,8% |
| 80–89 | 1.014 | 6.535 | 88,8% | 9,0% |
| 90 o más | 113 | 28.579 | 91,5% | 26,5% |

- La popularidad recién se dispara a partir de 80 puntos. Debajo de eso, el puntaje casi no cambia cuánta gente juega.
- Los jugadores puntúan en promedio **7,3 puntos más alto** que la crítica, y la correlación entre ambos es de **0,55**: van en la misma dirección, pero lejos de coincidir.
- Volumen no es satisfacción: *Monster Hunter Wilds* fue el más reseñado de 2025 con solo 58% positivo.

## Cómo está hecho

Los scripts se corren en orden:

| Archivo | Qué hace |
|---|---|
| `sql/00_carga_csv.sql` | Crea la base y carga el CSV con `BULK INSERT` |
| `sql/01_verificacion_carga.sql` | Controla la carga: cantidad de filas, columnas no corridas, acentos, duplicados |
| `sql/02_tabla_limpia.sql` | **Limpieza:** convierte tipos, lee fechas en inglés, pasa los Metacritic en 0 a vacío, separa el rango de dueños y calcula reseñas totales, % positivo y año |
| `sql/03_verificacion_limpieza.sql` | Controla la tabla limpia contra valores esperados |
| `sql/04_analisis_exploratorio.sql` | Brecha y correlación entre crítica y jugadores, por año, por género, juegos más reseñados |
| `sql/05_vistas_base.sql` | Vistas base para Power BI |
| `sql/06_goty_percentiles.sql` | Tabla de ganadores del GOTY y su percentil en crítica, aprobación y popularidad |
| `sql/07_goty_vs_su_anio.sql` | Puesto de cada ganador dentro de su año y vista para el gráfico de dispersión |
| `sql/08_critica_vs_popularidad.sql` | Mediana de reseñas por banda de Metacritic |

**Técnicas:** limpieza con `TRY_CAST` y `TRY_PARSE`, CTEs, funciones de ventana (`RANK`, `PERCENT_RANK`, `PERCENTILE_CONT`, `COUNT OVER`), `CROSS APPLY STRING_SPLIT`, vistas, correlación calculada en SQL.

## Decisiones

- **Reseñas como medida de cuánta gente jugó.** Steam no publica ventas, y los dueños estimados vienen en rangos muy amplios (por ejemplo, de 2 a 5 millones).
- **Mínimo de 500 reseñas** para no sacar conclusiones de juegos con muy poca muestra. Para comparar aprobación entre juegos de un mismo año se exigen 5.000.
- **Mediana en lugar de promedio** para las reseñas, porque unos pocos juegos gigantes distorsionan el promedio.
- **Solo Steam (PC).** Los GOTY 2016 (Overwatch), 2017 (Zelda: Breath of the Wild) y 2024 (Astro Bot) no tienen datos.

## Dashboard

Próximamente: dashboard en Power BI conectado a las vistas de este repositorio.

## Datos

[Steam Games Dataset](https://www.kaggle.com/datasets/fronkongames/steam-games-dataset) (Kaggle). El CSV no está en el repositorio por su tamaño.
