-- =============================================
-- Script: 01_CrearBaseDeDatos.sql
-- Proyecto: Base de datos Biblioteca (SQL Server)
-- Descripción: Crea la base de datos BibliotecaDB.
-- Nota: es el único script que se ejecuta desde master,
--       porque la base todavía no existe.
-- =============================================

-- Solo crea la base si todavía no existe,
-- así el script se puede ejecutar varias veces sin error.
IF DB_ID(N'BibliotecaDB') IS NULL
BEGIN
    CREATE DATABASE BibliotecaDB;
END
GO