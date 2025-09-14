-- ####################################################################
-- ####################################################################
-- ####################################################################
-- #############                                           ############
-- #############      CREACIÓN DE TABLAS PARA GAMEHUB      ############
-- #############                                           ############
-- ####################################################################
-- ####################################################################
-- ####################################################################

-- Creación de la tabla de Géneros de Videojuegos
CREATE TABLE generos (
    genero_id NUMBER PRIMARY KEY,
    nombre_genero VARCHAR2(50) NOT NULL UNIQUE
);

-- Creación de la tabla de Plataformas (Consolas/Sistemas)
CREATE TABLE plataformas (
    plataforma_id NUMBER PRIMARY KEY,
    nombre_plataforma VARCHAR2(50) NOT NULL UNIQUE
);

-- Creación de la tabla de Desarrolladores de Videojuegos
CREATE TABLE desarrolladores (
    desarrollador_id NUMBER PRIMARY KEY,
    nombre_desarrollador VARCHAR2(100) NOT NULL UNIQUE
);

-- Creación de la tabla de Videojuegos
CREATE TABLE videojuegos (
    videojuego_id NUMBER PRIMARY KEY,
    titulo VARCHAR2(150) NOT NULL,
    descripcion CLOB,
    fecha_lanzamiento DATE,
    precio NUMBER(8, 2) NOT NULL,
    stock NUMBER(5) DEFAULT 0,
    genero_id NUMBER,
    plataforma_id NUMBER,
    desarrollador_id NUMBER,
    CONSTRAINT fk_genero FOREIGN KEY (genero_id) REFERENCES generos(genero_id),
    CONSTRAINT fk_plataforma FOREIGN KEY (plataforma_id) REFERENCES plataformas(plataforma_id),
    CONSTRAINT fk_desarrollador FOREIGN KEY (desarrollador_id) REFERENCES desarrolladores(desarrollador_id)
);

-- Creación de la tabla de Clientes
CREATE TABLE clientes (
    cliente_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    apellido VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    fecha_registro DATE DEFAULT SYSDATE,
    telefono VARCHAR2(15)
);

-- Creación de la tabla de Ventas (Cabecera de la transacción)
CREATE TABLE ventas (
    venta_id NUMBER PRIMARY KEY,
    cliente_id NUMBER,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_venta NUMBER(10, 2),
    CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

-- Creación de la tabla de Detalles de Venta (Productos en cada transacción)
CREATE TABLE detalles_venta (
    detalle_id NUMBER PRIMARY KEY,
    venta_id NUMBER,
    videojuego_id NUMBER,
    cantidad NUMBER(3) NOT NULL,
    precio_unitario NUMBER(8, 2) NOT NULL,
    CONSTRAINT fk_venta FOREIGN KEY (venta_id) REFERENCES ventas(venta_id),
    CONSTRAINT fk_videojuego FOREIGN KEY (videojuego_id) REFERENCES videojuegos(videojuego_id)
);

-- Creación de secuencias para la generación automática de IDs
CREATE SEQUENCE seq_generos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_plataformas START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_desarrolladores START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_videojuegos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_clientes START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ventas START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_detalles_venta START WITH 1 INCREMENT BY 1;