-- =============================================
-- Script: 02_Catalogos.sql
-- Proyecto: Base de datos Biblioteca (SQL Server)
-- Descripción: Tablas de catálogo: Editoriales, Generos y Autores.
-- =============================================

-- Todo lo que sigue se ejecuta dentro de BibliotecaDB.
USE BibliotecaDB;
GO

-- Editoriales: casas editoras de los libros.
-- Se crea solo si no existe, así el script se puede repetir sin error.
IF OBJECT_ID(N'dbo.Editoriales', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Editoriales
    (
        IdEditorial INT IDENTITY(1,1) NOT NULL,   -- Clave primaria, se genera sola
        Nombre      NVARCHAR(120)     NOT NULL,   -- Nombre de la editorial

        CONSTRAINT PK_Editoriales PRIMARY KEY (IdEditorial),
        CONSTRAINT UQ_Editoriales_Nombre UNIQUE (Nombre)   -- No se repiten nombres
    );
END
GO

-- Generos: categorías de los libros (novela, ciencia, etc.).
IF OBJECT_ID(N'dbo.Generos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Generos
    (
        IdGenero SMALLINT IDENTITY(1,1) NOT NULL, -- Clave primaria (pocos géneros: SMALLINT basta)
        Nombre   NVARCHAR(80)           NOT NULL, -- Nombre del género

        CONSTRAINT PK_Generos PRIMARY KEY (IdGenero),
        CONSTRAINT UQ_Generos_Nombre UNIQUE (Nombre)
    );
END
GO

-- Autores: personas que escriben los libros.
IF OBJECT_ID(N'dbo.Autores', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Autores
    (
        IdAutor         INT IDENTITY(1,1) NOT NULL, -- Clave primaria
        Nombres         NVARCHAR(100)     NOT NULL, -- Nombre(s) del autor
        ApellidoPaterno NVARCHAR(60)      NOT NULL, -- Apellido principal
        ApellidoMaterno NVARCHAR(60)      NULL,     -- Opcional

        CONSTRAINT PK_Autores PRIMARY KEY (IdAutor)
    );
END
GO