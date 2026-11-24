-- =============================================
-- Script: 07_Procedimientos_Prestamos.sql
-- Proyecto: Base de datos Biblioteca (SQL Server)
-- Descripción: Procedimientos para registrar y devolver préstamos.
-- Requiere: 06_DatosDePrueba.sql ejecutado antes (para probarlos).
-- Errores propios: 50101 usuario no existe, 50102 plazo inválido,
--   50103 sin ejemplares, 50104 ejemplar no existe,
--   50105 ejemplar no disponible, 50111 ejemplar no existe (devolver),
--   50112 sin préstamo abierto.
-- =============================================

USE BibliotecaDB;
GO

-- Presta uno o varios ejemplares a un usuario. Devuelve el IdPrestamo.
CREATE OR ALTER PROCEDURE dbo.usp_Prestamos_Registrar
    @IdUsuario         INT,
    @CodigosEjemplares NVARCHAR(MAX),  -- Códigos separados por coma: N'CIEN-001, CIEN-002'
    @DiasPrestamo      INT = 14        -- Plazo en días (14 por defecto)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TransaccionPropia BIT = 0;  -- 1 si este procedimiento abrió la transacción
    DECLARE @Codigos TABLE (Codigo NVARCHAR(100) PRIMARY KEY);
    DECLARE @Pedidos INT, @Problema NVARCHAR(100), @Mensaje NVARCHAR(200), @IdPrestamo INT;

    BEGIN TRY
        -- Validaciones: no tocan datos todavía.
        IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE IdUsuario = @IdUsuario)
            THROW 50101, N'El usuario no existe.', 1;

        IF @DiasPrestamo NOT BETWEEN 1 AND 60
            THROW 50102, N'El plazo debe estar entre 1 y 60 días.', 1;

        -- Separa la lista, quita espacios, vacíos y repetidos.
        INSERT INTO @Codigos (Codigo)
        SELECT DISTINCT LTRIM(RTRIM(value))
        FROM STRING_SPLIT(@CodigosEjemplares, N',')
        WHERE LTRIM(RTRIM(value)) <> N'';

        SELECT @Pedidos = COUNT(*) FROM @Codigos;
        IF @Pedidos = 0
            THROW 50103, N'Debes indicar al menos un ejemplar.', 1;

        -- ¿Algún código no existe?
        SELECT TOP (1) @Problema = c.Codigo
        FROM @Codigos c
        LEFT JOIN dbo.Ejemplares e ON e.CodigoInterno = c.Codigo
        WHERE e.IdEjemplar IS NULL
        ORDER BY c.Codigo;
        IF @Problema IS NOT NULL
        BEGIN
            SET @Mensaje = CONCAT(N'No existe el ejemplar ', @Problema, N'.');
            THROW 50104, @Mensaje, 1;
        END

        -- ¿Algún ejemplar no está disponible?
        SELECT TOP (1) @Problema = e.CodigoInterno
        FROM @Codigos c
        JOIN dbo.Ejemplares e ON e.CodigoInterno = c.Codigo
        WHERE e.Estado <> N'disponible'
        ORDER BY e.CodigoInterno;
        IF @Problema IS NOT NULL
        BEGIN
            SET @Mensaje = CONCAT(N'El ejemplar ', @Problema, N' no está disponible.');
            THROW 50105, @Mensaje, 1;
        END

        -- Abre transacción solo si no hay una abierta.
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @TransaccionPropia = 1;
        END

        INSERT INTO dbo.Prestamos (IdUsuario, FechaLimite)
        VALUES (@IdUsuario, DATEADD(DAY, @DiasPrestamo, SYSDATETIME()));
        SET @IdPrestamo = SCOPE_IDENTITY();

        -- Marca como prestados SOLO los que siguen disponibles.
        UPDATE e
        SET Estado = N'prestado'
        FROM dbo.Ejemplares e
        JOIN @Codigos c ON c.Codigo = e.CodigoInterno
        WHERE e.Estado = N'disponible';

        -- Si alguien tomó uno justo ahora, no coinciden las filas: se cancela todo.
        IF @@ROWCOUNT <> @Pedidos
            THROW 50105, N'Un ejemplar dejó de estar disponible. Intenta de nuevo.', 1;

        INSERT INTO dbo.PrestamoDetalles (IdPrestamo, IdEjemplar)
        SELECT @IdPrestamo, e.IdEjemplar
        FROM dbo.Ejemplares e
        JOIN @Codigos c ON c.Codigo = e.CodigoInterno;

        IF @TransaccionPropia = 1
            COMMIT TRANSACTION;

        SELECT @IdPrestamo AS IdPrestamo;
    END TRY
    BEGIN CATCH
        -- Deshace solo lo que este procedimiento abrió y vuelve a lanzar el error.
        IF @TransaccionPropia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Devuelve un ejemplar por su código y responde con los días de retraso.
CREATE OR ALTER PROCEDURE dbo.usp_Prestamos_Devolver
    @CodigoEjemplar NVARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TransaccionPropia BIT = 0;
    DECLARE @IdEjemplar INT, @IdPrestamo INT;

    BEGIN TRY
        SELECT @IdEjemplar = IdEjemplar
        FROM dbo.Ejemplares
        WHERE CodigoInterno = LTRIM(RTRIM(@CodigoEjemplar));

        IF @IdEjemplar IS NULL
            THROW 50111, N'El ejemplar no existe.', 1;

        -- Busca el préstamo abierto (el índice único filtrado garantiza máximo uno).
        SELECT @IdPrestamo = IdPrestamo
        FROM dbo.PrestamoDetalles
        WHERE IdEjemplar = @IdEjemplar AND FechaDevolucion IS NULL;

        IF @IdPrestamo IS NULL
            THROW 50112, N'El ejemplar no tiene un préstamo abierto.', 1;

        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @TransaccionPropia = 1;
        END

        UPDATE dbo.PrestamoDetalles
        SET FechaDevolucion = SYSDATETIME()
        WHERE IdPrestamo = @IdPrestamo AND IdEjemplar = @IdEjemplar AND FechaDevolucion IS NULL;

        UPDATE dbo.Ejemplares
        SET Estado = N'disponible'
        WHERE IdEjemplar = @IdEjemplar;

        IF @TransaccionPropia = 1
            COMMIT TRANSACTION;

        -- Resultado: fecha de devolución y días de retraso (0 si llegó a tiempo).
        SELECT p.IdPrestamo,
               @CodigoEjemplar AS Codigo,
               d.FechaDevolucion,
               CASE WHEN d.FechaDevolucion > p.FechaLimite
                    THEN DATEDIFF(DAY, p.FechaLimite, d.FechaDevolucion)
                    ELSE 0 END AS DiasRetraso
        FROM dbo.PrestamoDetalles d
        JOIN dbo.Prestamos p ON p.IdPrestamo = d.IdPrestamo
        WHERE d.IdPrestamo = @IdPrestamo AND d.IdEjemplar = @IdEjemplar;
    END TRY
    BEGIN CATCH
        IF @TransaccionPropia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO