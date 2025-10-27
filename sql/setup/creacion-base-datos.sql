DROP TABLE genero CASCADE CONSTRAINTS;
DROP TABLE plataforma CASCADE CONSTRAINTS;
DROP TABLE desarrollador CASCADE CONSTRAINTS;
DROP TABLE videojuego CASCADE CONSTRAINTS;
DROP TABLE cliente CASCADE CONSTRAINTS;
DROP TABLE venta CASCADE CONSTRAINTS;
DROP TABLE detalle_venta CASCADE CONSTRAINTS;

DROP SEQUENCE seq_genero;
DROP SEQUENCE seq_plataforma;
DROP SEQUENCE seq_desarrollador;
DROP SEQUENCE seq_videojuego;
DROP SEQUENCE seq_cliente;
DROP SEQUENCE seq_venta;
DROP SEQUENCE seq_detalle_venta;


CREATE TABLE genero (
    genero_id NUMBER PRIMARY KEY,
    nombre_genero VARCHAR2(50) NOT NULL UNIQUE
);

CREATE TABLE plataforma (
    plataforma_id NUMBER PRIMARY KEY,
    nombre_plataforma VARCHAR2(50) NOT NULL UNIQUE
);

CREATE TABLE desarrollador (
    desarrollador_id NUMBER PRIMARY KEY,
    nombre_desarrollador VARCHAR2(100) NOT NULL UNIQUE
);

CREATE TABLE videojuego (
    videojuego_id NUMBER PRIMARY KEY,
    titulo VARCHAR2(150) NOT NULL,
    descripcion CLOB,
    fecha_lanzamiento DATE,
    precio NUMBER(8, 2) NOT NULL,
    stock NUMBER(5) DEFAULT 0,
    genero_id NUMBER,
    plataforma_id NUMBER,
    desarrollador_id NUMBER,
    CONSTRAINT fk_genero FOREIGN KEY (genero_id) REFERENCES genero(genero_id),
    CONSTRAINT fk_plataforma FOREIGN KEY (plataforma_id) REFERENCES plataforma(plataforma_id),
    CONSTRAINT fk_desarrollador FOREIGN KEY (desarrollador_id) REFERENCES desarrollador(desarrollador_id)
);

CREATE TABLE cliente (
    cliente_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    apellido VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    fecha_registro DATE DEFAULT SYSDATE,
    telefono VARCHAR2(15)
);

CREATE TABLE venta (
    venta_id NUMBER PRIMARY KEY,
    cliente_id NUMBER,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_venta NUMBER(10, 2),
    CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
);

CREATE TABLE detalle_venta (
    detalle_id NUMBER PRIMARY KEY,
    venta_id NUMBER,
    videojuego_id NUMBER,
    cantidad NUMBER(3) NOT NULL,
    precio_unitario NUMBER(8, 2) NOT NULL,
    CONSTRAINT fk_venta FOREIGN KEY (venta_id) REFERENCES venta(venta_id),
    CONSTRAINT fk_videojuego FOREIGN KEY (videojuego_id) REFERENCES videojuego(videojuego_id)
);

-- Creación de secuencias para la generación automática de IDs
CREATE SEQUENCE seq_genero START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_plataforma START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_desarrollador START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_videojuego START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cliente START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_venta START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_detalle_venta START WITH 1 INCREMENT BY 1;