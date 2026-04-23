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

-- =================================================
-- Ejemplares, usuarios y préstamos
-- =================================================

-- Tabla ejemplar
-- Representa cada copia física de un libro
CREATE TABLE ejemplar (
    id_ejemplar INT NOT NULL AUTO_INCREMENT,    -- Clave primaria
    id_libro INT NOT NULL,                       -- Libro al que pertenece
    codigo_interno VARCHAR(40) NOT NULL,         -- Código único del ejemplar
    estado ENUM('disponible','prestado') 
           NOT NULL DEFAULT 'disponible',        -- Estado del ejemplar
    PRIMARY KEY (id_ejemplar),
    UNIQUE (codigo_interno),
    FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
) ENGINE=InnoDB;

-- Tabla usuario
-- Almacena los usuarios que pueden pedir libros
CREATE TABLE usuario (
    id_usuario INT NOT NULL AUTO_INCREMENT,      -- Clave primaria
    nombre VARCHAR(100) NOT NULL,                 -- Nombre del usuario
    PRIMARY KEY (id_usuario)
) ENGINE=InnoDB;

-- Tabla prestamo
-- Registro de cada préstamo realizado
CREATE TABLE prestamo (
    id_prestamo INT NOT NULL AUTO_INCREMENT,     -- Clave primaria
    id_usuario INT NOT NULL,                      -- Usuario que realiza el préstamo
    fecha_prestamo DATETIME 
        NOT NULL DEFAULT CURRENT_TIMESTAMP,       -- Fecha del préstamo
    PRIMARY KEY (id_prestamo),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;

-- Tabla prestamo_detalle
-- Relaciona préstamos con ejemplares específicos
CREATE TABLE prestamo_detalle (
    id_prestamo INT NOT NULL,                     -- Préstamo
    id_ejemplar INT NOT NULL,                     -- Ejemplar prestado
    PRIMARY KEY (id_prestamo, id_ejemplar),
    FOREIGN KEY (id_prestamo) REFERENCES prestamo(id_prestamo),
    FOREIGN KEY (id_ejemplar) REFERENCES ejemplar(id_ejemplar)
) ENGINE=InnoDB;