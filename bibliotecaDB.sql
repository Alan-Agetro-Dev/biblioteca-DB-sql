/*
=================================================
Proyecto: Base de Datos Biblioteca
Día 1: Tablas de catálogo
Autor: Alan Humberto Ortega Aguayo
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

