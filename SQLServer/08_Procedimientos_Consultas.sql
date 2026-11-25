-- =============================================
-- Script: 08_Procedimientos_Consultas.sql
-- Proyecto: Base de datos Biblioteca (SQL Server)
-- Descripción: Procedimientos de consulta (solo lectura):
--              libros disponibles y préstamos vencidos.
-- Requiere: 07_Procedimientos_Prestamos.sql ejecutado antes.
-- =============================================

USE BibliotecaDB;
GO

-- Libros con al menos un ejemplar disponible.
-- @Titulo es opcional: busca por parte del título; si es NULL, devuelve todos.
CREATE OR ALTER PROCEDURE dbo.usp_Libros_ObtenerDisponibles
    @Titulo NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT l.IdLibro,
           l.Titulo,
           -- Junta los autores del libro en una sola celda, ordenados por apellido.
           (SELECT STRING_AGG(CONCAT(a.Nombres, N' ', a.ApellidoPaterno), N', ')
                   WITHIN GROUP (ORDER BY a.ApellidoPaterno)
            FROM dbo.LibroAutores la
            JOIN dbo.Autores a ON a.IdAutor = la.IdAutor
            WHERE la.IdLibro = l.IdLibro) AS Autores,
           ed.Nombre AS Editorial,
           g.Nombre  AS Genero,
           COUNT(e.IdEjemplar) AS EjemplaresDisponibles
    FROM dbo.Libros l
    JOIN dbo.Editoriales ed ON ed.IdEditorial = l.IdEditorial
    JOIN dbo.Generos g      ON g.IdGenero = l.IdGenero
    -- El JOIN solo trae ejemplares disponibles: los libros sin ninguno no aparecen.
    JOIN dbo.Ejemplares e   ON e.IdLibro = l.IdLibro AND e.Estado = N'disponible'
    WHERE @Titulo IS NULL OR l.Titulo LIKE N'%' + @Titulo + N'%'
    GROUP BY l.IdLibro, l.Titulo, ed.Nombre, g.Nombre
    ORDER BY l.Titulo;
END
GO

-- Ejemplares sin devolver cuya fecha límite ya pasó.
-- Ordenados del mayor al menor retraso.
CREATE OR ALTER PROCEDURE dbo.usp_Prestamos_ObtenerVencidos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.Nombre AS Usuario,
           u.Email,
           l.Titulo,
           e.CodigoInterno,
           p.FechaLimite,
           DATEDIFF(DAY, p.FechaLimite, SYSDATETIME()) AS DiasRetraso
    FROM dbo.PrestamoDetalles d
    JOIN dbo.Prestamos p  ON p.IdPrestamo = d.IdPrestamo
    JOIN dbo.Usuarios u   ON u.IdUsuario = p.IdUsuario
    JOIN dbo.Ejemplares e ON e.IdEjemplar = d.IdEjemplar
    JOIN dbo.Libros l     ON l.IdLibro = e.IdLibro
    WHERE d.FechaDevolucion IS NULL
      AND p.FechaLimite < SYSDATETIME()
    ORDER BY DiasRetraso DESC, u.Nombre, l.Titulo;
END
GO