-- =============================================
-- Script: 03_Libros_Ejemplares_Usuarios.sql
-- Proyecto: Base de datos Biblioteca (SQL Server)
-- Descripción: Libros, LibroAutores (muchos a muchos),
--              Ejemplares y Usuarios.
-- Requiere: 02_Catalogos.sql ejecutado antes.
-- =============================================

USE BibliotecaDB;
GO

-- Libros: cada título del catálogo de la biblioteca.
IF OBJECT_ID(N'dbo.Libros', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Libros
    (
        IdLibro     INT IDENTITY(1,1) NOT NULL,  -- Clave primaria
        Titulo      NVARCHAR(200)     NOT NULL,  -- Título del libro
        IdEditorial INT               NOT NULL,  -- Editorial que lo publica
        IdGenero    SMALLINT          NOT NULL,  -- Género del libro

        CONSTRAINT PK_Libros PRIMARY KEY (IdLibro),
        CONSTRAINT FK_Libros_Editoriales FOREIGN KEY (IdEditorial)
            REFERENCES dbo.Editoriales (IdEditorial),
        CONSTRAINT FK_Libros_Generos FOREIGN KEY (IdGenero)
            REFERENCES dbo.Generos (IdGenero)
    );
END
GO

-- LibroAutores: relaciona libros con autores (muchos a muchos).
-- La clave primaria compuesta impide repetir el mismo autor en un libro.
IF OBJECT_ID(N'dbo.LibroAutores', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LibroAutores
    (
        IdLibro INT NOT NULL,
        IdAutor INT NOT NULL,

        CONSTRAINT PK_LibroAutores PRIMARY KEY (IdLibro, IdAutor),
        CONSTRAINT FK_LibroAutores_Libros FOREIGN KEY (IdLibro)
            REFERENCES dbo.Libros (IdLibro),
        CONSTRAINT FK_LibroAutores_Autores FOREIGN KEY (IdAutor)
            REFERENCES dbo.Autores (IdAutor)
    );
END
GO

-- Ejemplares: cada copia física de un libro.
IF OBJECT_ID(N'dbo.Ejemplares', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Ejemplares
    (
        IdEjemplar    INT IDENTITY(1,1) NOT NULL,  -- Clave primaria
        IdLibro       INT               NOT NULL,  -- Libro al que pertenece
        CodigoInterno NVARCHAR(40)      NOT NULL,  -- Código único de la copia
        Estado        NVARCHAR(20)      NOT NULL   -- Disponible o prestado
            CONSTRAINT DF_Ejemplares_Estado DEFAULT N'disponible',

        CONSTRAINT PK_Ejemplares PRIMARY KEY (IdEjemplar),
        CONSTRAINT UQ_Ejemplares_CodigoInterno UNIQUE (CodigoInterno),
        -- CHECK reemplaza al ENUM de MariaDB: solo acepta estos dos valores.
        CONSTRAINT CK_Ejemplares_Estado CHECK (Estado IN (N'disponible', N'prestado')),
        CONSTRAINT FK_Ejemplares_Libros FOREIGN KEY (IdLibro)
            REFERENCES dbo.Libros (IdLibro)
    );
END
GO

-- Usuarios: personas que pueden pedir libros prestados.
IF OBJECT_ID(N'dbo.Usuarios', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Usuarios
    (
        IdUsuario INT IDENTITY(1,1) NOT NULL,  -- Clave primaria
        Nombre    NVARCHAR(100)     NOT NULL,  -- Nombre completo
        Email     NVARCHAR(120)     NOT NULL,  -- Correo, no se puede repetir

        CONSTRAINT PK_Usuarios PRIMARY KEY (IdUsuario),
        CONSTRAINT UQ_Usuarios_Email UNIQUE (Email)
    );
END
GO