-- =============================================
-- Script: 05_Indices.sql
-- Proyecto: Base de datos Biblioteca (SQL Server)
-- Descripción: Índices sobre claves foráneas y la regla
--              "un ejemplar solo puede tener un préstamo sin devolver".
-- Requiere: 04_Prestamos.sql ejecutado antes.
-- =============================================

USE BibliotecaDB;
GO

-- ---------------------------------------------
-- Índices sobre claves foráneas
-- (SQL Server no los crea automáticamente)
-- ---------------------------------------------

-- Libros por editorial
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_Libros_IdEditorial'
                 AND object_id = OBJECT_ID(N'dbo.Libros'))
    CREATE NONCLUSTERED INDEX IX_Libros_IdEditorial ON dbo.Libros (IdEditorial);
GO

-- Libros por género
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_Libros_IdGenero'
                 AND object_id = OBJECT_ID(N'dbo.Libros'))
    CREATE NONCLUSTERED INDEX IX_Libros_IdGenero ON dbo.Libros (IdGenero);
GO

-- Libros de un autor (IdLibro ya está cubierto por la clave primaria compuesta)
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_LibroAutores_IdAutor'
                 AND object_id = OBJECT_ID(N'dbo.LibroAutores'))
    CREATE NONCLUSTERED INDEX IX_LibroAutores_IdAutor ON dbo.LibroAutores (IdAutor);
GO

-- Ejemplares de un libro
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_Ejemplares_IdLibro'
                 AND object_id = OBJECT_ID(N'dbo.Ejemplares'))
    CREATE NONCLUSTERED INDEX IX_Ejemplares_IdLibro ON dbo.Ejemplares (IdLibro);
GO

-- Préstamos de un usuario
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_Prestamos_IdUsuario'
                 AND object_id = OBJECT_ID(N'dbo.Prestamos'))
    CREATE NONCLUSTERED INDEX IX_Prestamos_IdUsuario ON dbo.Prestamos (IdUsuario);
GO

-- Historial de préstamos de un ejemplar (IdPrestamo ya está en la clave primaria)
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_PrestamoDetalles_IdEjemplar'
                 AND object_id = OBJECT_ID(N'dbo.PrestamoDetalles'))
    CREATE NONCLUSTERED INDEX IX_PrestamoDetalles_IdEjemplar ON dbo.PrestamoDetalles (IdEjemplar);
GO

-- ---------------------------------------------
-- Regla de negocio: un ejemplar solo puede estar
-- en UN préstamo sin devolver a la vez.
-- El índice único aplica solo a las filas con FechaDevolucion NULL,
-- así que el historial de devoluciones puede repetir el ejemplar.
-- ---------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'UX_PrestamoDetalles_EjemplarPrestado'
                 AND object_id = OBJECT_ID(N'dbo.PrestamoDetalles'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_PrestamoDetalles_EjemplarPrestado
        ON dbo.PrestamoDetalles (IdEjemplar)
        WHERE FechaDevolucion IS NULL;
GO