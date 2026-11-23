-- =============================================
-- Script: 04_Prestamos.sql
-- Proyecto: Base de datos Biblioteca (SQL Server)
-- Descripción: Prestamos y PrestamoDetalles, con fecha límite
--              y fecha de devolución.
-- Requiere: 03_Libros_Ejemplares_Usuarios.sql ejecutado antes.
-- =============================================

USE BibliotecaDB;
GO

-- Prestamos: cada vez que un usuario se lleva uno o más libros.
IF OBJECT_ID(N'dbo.Prestamos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Prestamos
    (
        IdPrestamo   INT IDENTITY(1,1) NOT NULL,   -- Clave primaria
        IdUsuario    INT               NOT NULL,   -- Quién realiza el préstamo
        FechaPrestamo DATETIME2        NOT NULL    -- Se asigna sola al registrar
            CONSTRAINT DF_Prestamos_FechaPrestamo DEFAULT SYSDATETIME(),
        FechaLimite  DATETIME2         NOT NULL,   -- Hasta cuándo puede tenerlos

        CONSTRAINT PK_Prestamos PRIMARY KEY (IdPrestamo),
        CONSTRAINT FK_Prestamos_Usuarios FOREIGN KEY (IdUsuario)
            REFERENCES dbo.Usuarios (IdUsuario),
        -- La fecha límite debe ser posterior a la del préstamo.
        CONSTRAINT CK_Prestamos_FechaLimite CHECK (FechaLimite > FechaPrestamo)
    );
END
GO

-- PrestamoDetalles: los ejemplares incluidos en cada préstamo.
-- FechaDevolucion queda en NULL mientras el ejemplar no se devuelve.
IF OBJECT_ID(N'dbo.PrestamoDetalles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PrestamoDetalles
    (
        IdPrestamo      INT       NOT NULL,   -- Préstamo al que pertenece
        IdEjemplar      INT       NOT NULL,   -- Ejemplar prestado
        FechaDevolucion DATETIME2 NULL,       -- NULL = aún no devuelto

        -- La clave compuesta impide repetir el mismo ejemplar en un préstamo.
        CONSTRAINT PK_PrestamoDetalles PRIMARY KEY (IdPrestamo, IdEjemplar),
        CONSTRAINT FK_PrestamoDetalles_Prestamos FOREIGN KEY (IdPrestamo)
            REFERENCES dbo.Prestamos (IdPrestamo),
        CONSTRAINT FK_PrestamoDetalles_Ejemplares FOREIGN KEY (IdEjemplar)
            REFERENCES dbo.Ejemplares (IdEjemplar)
    );
END
GO