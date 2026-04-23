/*
Proyecto: Base de Datos Biblioteca
Autor: Alan Ortega

=================================================
--Tablas de catálogo
=================================================
*/

-- Tabla editorial
-- Guarda las editoriales de los libros
CREATE TABLE editorial (
    id_editorial INT NOT NULL AUTO_INCREMENT, -- Clave primaria
    nombre VARCHAR(120) NOT NULL,              -- Nombre de la editorial
    PRIMARY KEY (id_editorial),
    UNIQUE (nombre)
) ENGINE=InnoDB;

-- Tabla género
CREATE TABLE genero (
    id_genero SMALLINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_genero),
    UNIQUE (nombre)
) ENGINE=InnoDB;

-- =================================================
-- Autores y libros
-- =================================================

-- Tabla autor
-- Almacena la información de los autores
CREATE TABLE autor (
    id_autor INT NOT NULL AUTO_INCREMENT,   -- Clave primaria
    nombres VARCHAR(100) NOT NULL,           -- Nombres del autor
    apellido_paterno VARCHAR(60) NOT NULL,   -- Apellido principal
    PRIMARY KEY (id_autor)
) ENGINE=InnoDB;

-- Tabla libro
-- Representa cada libro disponible en la biblioteca
CREATE TABLE libro (
    id_libro INT NOT NULL AUTO_INCREMENT,    -- Clave primaria
    titulo VARCHAR(200) NOT NULL,             -- Título del libro
    id_genero SMALLINT,                       -- Género del libro
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero)
) ENGINE=InnoDB;