/* ==================================================================
   00 - Carga del CSV a SQL Server
   Crea la base y la tabla cruda, y carga el archivo tal cual viene.

   Solo hace falta correrlo si cargás los datos desde cero.
   Antes de correrlo, cambiá la ruta del archivo en el BULK INSERT.
   ================================================================== */

IF DB_ID('steam_analysis') IS NULL
    CREATE DATABASE steam_analysis;
GO

USE steam_analysis;
GO

DROP TABLE IF EXISTS dbo.steam_games_raw;
GO

-- Todo como texto: primero cargamos, después convertimos en la limpieza.
CREATE TABLE dbo.steam_games_raw (
    app_id                  nvarchar(20),
    name                    nvarchar(500),
    release_date            nvarchar(50),
    estimated_owners        nvarchar(50),
    peak_ccu                nvarchar(20),
    price                   nvarchar(20),
    metacritic_score        nvarchar(10),
    positive_reviews        nvarchar(20),
    negative_reviews        nvarchar(20),
    recommendations         nvarchar(20),
    avg_playtime_minutes    nvarchar(20),
    median_playtime_minutes nvarchar(20),
    developers              nvarchar(max),
    genres                  nvarchar(max)
);
GO

BULK INSERT dbo.steam_games_raw
FROM 'C:\datos\steam_games_slim.csv'   -- << cambiar por tu ruta
WITH (
    FORMAT          = 'CSV',     -- respeta las comas dentro de comillas
    FIRSTROW        = 2,         -- saltea el encabezado
    CODEPAGE        = '65001',   -- UTF-8: mantiene acentos y símbolos
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a'
);
GO

SELECT COUNT(*) AS filas_cargadas FROM dbo.steam_games_raw;  -- debe dar 125855
