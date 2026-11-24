-- =============================================
-- Script: 06_DatosDePrueba.sql
-- Proyecto: Base de datos Biblioteca (SQL Server)
-- Descripción: Datos de ejemplo. Se puede ejecutar varias veces
--              sin duplicar información.
-- Requiere: 05_Indices.sql ejecutado antes.
-- =============================================

USE BibliotecaDB;
GO

-- ---------------------------------------------
-- Catálogos (cada fila se inserta solo si no existe)
-- ---------------------------------------------
INSERT INTO dbo.Editoriales (Nombre)
SELECT v.Nombre
FROM (VALUES (N'Alfaguara'), (N'Fondo de Cultura Económica'),
             (N'Planeta'), (N'Minotauro')) AS v(Nombre)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Editoriales e WHERE e.Nombre = v.Nombre);

INSERT INTO dbo.Generos (Nombre)
SELECT v.Nombre
FROM (VALUES (N'Novela'), (N'Ensayo'), (N'Ciencia'), (N'Fantasía')) AS v(Nombre)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Generos g WHERE g.Nombre = v.Nombre);

-- Autores: se compara por nombre y apellido paterno.
INSERT INTO dbo.Autores (Nombres, ApellidoPaterno, ApellidoMaterno)
SELECT v.Nombres, v.ApellidoPaterno, v.ApellidoMaterno
FROM (VALUES (N'Gabriel', N'García',  N'Márquez'),
             (N'Juan',    N'Rulfo',   NULL),
             (N'Octavio', N'Paz',     NULL),
             (N'Laura',   N'Esquivel',NULL),
             (N'Carl',    N'Sagan',   NULL),
             (N'Terry',   N'Pratchett', NULL),
             (N'Neil',    N'Gaiman',  NULL),
             (N'Mario',   N'Vargas',  N'Llosa')) AS v(Nombres, ApellidoPaterno, ApellidoMaterno)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Autores a
                  WHERE a.Nombres = v.Nombres AND a.ApellidoPaterno = v.ApellidoPaterno);
GO

-- ---------------------------------------------
-- Libros (editorial y género se buscan por nombre)
-- ---------------------------------------------
INSERT INTO dbo.Libros (Titulo, IdEditorial, IdGenero)
SELECT v.Titulo, e.IdEditorial, g.IdGenero
FROM (VALUES (N'Cien años de soledad',         N'Alfaguara',                 N'Novela'),
             (N'Pedro Páramo',                 N'Fondo de Cultura Económica',N'Novela'),
             (N'El laberinto de la soledad',   N'Fondo de Cultura Económica',N'Ensayo'),
             (N'Como agua para chocolate',     N'Planeta',                   N'Novela'),
             (N'Cosmos',                       N'Planeta',                   N'Ciencia'),
             (N'Buenos presagios',             N'Minotauro',                 N'Fantasía'),
             (N'La ciudad y los perros',       N'Alfaguara',                 N'Novela')
     ) AS v(Titulo, Editorial, Genero)
JOIN dbo.Editoriales e ON e.Nombre = v.Editorial
JOIN dbo.Generos g     ON g.Nombre = v.Genero
WHERE NOT EXISTS (SELECT 1 FROM dbo.Libros l WHERE l.Titulo = v.Titulo);
GO

-- ---------------------------------------------
-- Autores de cada libro (muchos a muchos)
-- "Buenos presagios" tiene dos autores.
-- ---------------------------------------------
INSERT INTO dbo.LibroAutores (IdLibro, IdAutor)
SELECT l.IdLibro, a.IdAutor
FROM (VALUES (N'Cien años de soledad',       N'Gabriel', N'García'),
             (N'Pedro Páramo',               N'Juan',    N'Rulfo'),
             (N'El laberinto de la soledad', N'Octavio', N'Paz'),
             (N'Como agua para chocolate',   N'Laura',   N'Esquivel'),
             (N'Cosmos',                     N'Carl',    N'Sagan'),
             (N'Buenos presagios',           N'Terry',   N'Pratchett'),
             (N'Buenos presagios',           N'Neil',    N'Gaiman'),
             (N'La ciudad y los perros',     N'Mario',   N'Vargas')
     ) AS v(Titulo, Nombres, ApellidoPaterno)
JOIN dbo.Libros l   ON l.Titulo = v.Titulo
JOIN dbo.Autores a  ON a.Nombres = v.Nombres AND a.ApellidoPaterno = v.ApellidoPaterno
WHERE NOT EXISTS (SELECT 1 FROM dbo.LibroAutores la
                  WHERE la.IdLibro = l.IdLibro AND la.IdAutor = a.IdAutor);
GO

-- ---------------------------------------------
-- Ejemplares (el estado inicial es "disponible")
-- ---------------------------------------------
INSERT INTO dbo.Ejemplares (IdLibro, CodigoInterno)
SELECT l.IdLibro, v.Codigo
FROM (VALUES (N'CIEN-001', N'Cien años de soledad'),
             (N'CIEN-002', N'Cien años de soledad'),
             (N'PEPA-001', N'Pedro Páramo'),
             (N'LABE-001', N'El laberinto de la soledad'),
             (N'AGUA-001', N'Como agua para chocolate'),
             (N'AGUA-002', N'Como agua para chocolate'),
             (N'COSM-001', N'Cosmos'),
             (N'PRES-001', N'Buenos presagios'),
             (N'CIUD-001', N'La ciudad y los perros')) AS v(Codigo, Titulo)
JOIN dbo.Libros l ON l.Titulo = v.Titulo
WHERE NOT EXISTS (SELECT 1 FROM dbo.Ejemplares e WHERE e.CodigoInterno = v.Codigo);
GO

-- ---------------------------------------------
-- Usuarios
-- ---------------------------------------------
INSERT INTO dbo.Usuarios (Nombre, Email)
SELECT v.Nombre, v.Email
FROM (VALUES (N'Ana López',       N'ana.lopez@ejemplo.com'),
             (N'Luis Hernández',  N'luis.hernandez@ejemplo.com'),
             (N'María Torres',    N'maria.torres@ejemplo.com'),
             (N'Carlos Ramírez',  N'carlos.ramirez@ejemplo.com')) AS v(Nombre, Email)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Usuarios u WHERE u.Email = v.Email);
GO

-- ---------------------------------------------
-- Préstamos de ejemplo
-- Solo se cargan si la tabla Prestamos está vacía.
-- XACT_ABORT + transacción: si algo falla, no queda nada a medias.
-- ---------------------------------------------
SET XACT_ABORT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.Prestamos)
BEGIN
    BEGIN TRANSACTION;

    DECLARE @IdAna    INT = (SELECT IdUsuario FROM dbo.Usuarios WHERE Email = N'ana.lopez@ejemplo.com');
    DECLARE @IdLuis   INT = (SELECT IdUsuario FROM dbo.Usuarios WHERE Email = N'luis.hernandez@ejemplo.com');
    DECLARE @IdMaria  INT = (SELECT IdUsuario FROM dbo.Usuarios WHERE Email = N'maria.torres@ejemplo.com');
    DECLARE @IdCarlos INT = (SELECT IdUsuario FROM dbo.Usuarios WHERE Email = N'carlos.ramirez@ejemplo.com');
    DECLARE @IdPrestamo INT;

    -- Préstamo 1 (Ana): ya devuelto, queda como historial.
    INSERT INTO dbo.Prestamos (IdUsuario, FechaPrestamo, FechaLimite)
    VALUES (@IdAna, DATEADD(DAY, -40, SYSDATETIME()), DATEADD(DAY, -26, SYSDATETIME()));
    SET @IdPrestamo = SCOPE_IDENTITY();
    INSERT INTO dbo.PrestamoDetalles (IdPrestamo, IdEjemplar, FechaDevolucion)
    SELECT @IdPrestamo, IdEjemplar, DATEADD(DAY, -30, SYSDATETIME())
    FROM dbo.Ejemplares WHERE CodigoInterno = N'CIEN-001';

    -- Préstamo 2 (Luis): VENCIDO, dos libros sin devolver.
    INSERT INTO dbo.Prestamos (IdUsuario, FechaPrestamo, FechaLimite)
    VALUES (@IdLuis, DATEADD(DAY, -20, SYSDATETIME()), DATEADD(DAY, -6, SYSDATETIME()));
    SET @IdPrestamo = SCOPE_IDENTITY();
    INSERT INTO dbo.PrestamoDetalles (IdPrestamo, IdEjemplar)
    SELECT @IdPrestamo, IdEjemplar
    FROM dbo.Ejemplares WHERE CodigoInterno IN (N'PEPA-001', N'LABE-001');

    -- Préstamo 3 (María): vigente, aún dentro del plazo.
    INSERT INTO dbo.Prestamos (IdUsuario, FechaPrestamo, FechaLimite)
    VALUES (@IdMaria, DATEADD(DAY, -3, SYSDATETIME()), DATEADD(DAY, 11, SYSDATETIME()));
    SET @IdPrestamo = SCOPE_IDENTITY();
    INSERT INTO dbo.PrestamoDetalles (IdPrestamo, IdEjemplar)
    SELECT @IdPrestamo, IdEjemplar
    FROM dbo.Ejemplares WHERE CodigoInterno = N'COSM-001';

    -- Préstamo 4 (Carlos): un libro devuelto y otro todavía prestado.
    INSERT INTO dbo.Prestamos (IdUsuario, FechaPrestamo, FechaLimite)
    VALUES (@IdCarlos, DATEADD(DAY, -8, SYSDATETIME()), DATEADD(DAY, 6, SYSDATETIME()));
    SET @IdPrestamo = SCOPE_IDENTITY();
    INSERT INTO dbo.PrestamoDetalles (IdPrestamo, IdEjemplar, FechaDevolucion)
    SELECT @IdPrestamo, IdEjemplar, DATEADD(DAY, -1, SYSDATETIME())
    FROM dbo.Ejemplares WHERE CodigoInterno = N'AGUA-001';
    INSERT INTO dbo.PrestamoDetalles (IdPrestamo, IdEjemplar)
    SELECT @IdPrestamo, IdEjemplar
    FROM dbo.Ejemplares WHERE CodigoInterno = N'PRES-001';

    COMMIT TRANSACTION;
END
GO

-- ---------------------------------------------
-- Coherencia: los ejemplares con préstamo sin devolver quedan "prestado".
-- ---------------------------------------------
UPDATE e
SET Estado = N'prestado'
FROM dbo.Ejemplares e
WHERE EXISTS (SELECT 1 FROM dbo.PrestamoDetalles d
              WHERE d.IdEjemplar = e.IdEjemplar AND d.FechaDevolucion IS NULL);
GO