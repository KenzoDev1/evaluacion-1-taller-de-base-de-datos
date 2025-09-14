-- ####################################################################
-- ####################################################################
-- ####################################################################
-- #############                                           ############
-- #############       POBLACIÓN DE TABLAS PARA GAMEHUB      ############
-- #############                                           ############
-- ####################################################################
-- ####################################################################
-- ####################################################################

-- Insertar Géneros
INSERT INTO generos (genero_id, nombre_genero) VALUES (seq_generos.NEXTVAL, 'Acción');
INSERT INTO generos (genero_id, nombre_genero) VALUES (seq_generos.NEXTVAL, 'Aventura');
INSERT INTO generos (genero_id, nombre_genero) VALUES (seq_generos.NEXTVAL, 'RPG');
INSERT INTO generos (genero_id, nombre_genero) VALUES (seq_generos.NEXTVAL, 'Estrategia');
INSERT INTO generos (genero_id, nombre_genero) VALUES (seq_generos.NEXTVAL, 'Deportes');
INSERT INTO generos (genero_id, nombre_genero) VALUES (seq_generos.NEXTVAL, 'Simulación');
INSERT INTO generos (genero_id, nombre_genero) VALUES (seq_generos.NEXTVAL, 'Puzzle');
INSERT INTO generos (genero_id, nombre_genero) VALUES (seq_generos.NEXTVAL, 'Terror');

-- Insertar Plataformas
INSERT INTO plataformas (plataforma_id, nombre_plataforma) VALUES (seq_plataformas.NEXTVAL, 'PC');
INSERT INTO plataformas (plataforma_id, nombre_plataforma) VALUES (seq_plataformas.NEXTVAL, 'PlayStation 5');
INSERT INTO plataformas (plataforma_id, nombre_plataforma) VALUES (seq_plataformas.NEXTVAL, 'Xbox Series X');
INSERT INTO plataformas (plataforma_id, nombre_plataforma) VALUES (seq_plataformas.NEXTVAL, 'Nintendo Switch');

-- Insertar Desarrolladores
INSERT INTO desarrolladores (desarrollador_id, nombre_desarrollador) VALUES (seq_desarrolladores.NEXTVAL, 'CD Projekt Red');
INSERT INTO desarrolladores (desarrollador_id, nombre_desarrollador) VALUES (seq_desarrolladores.NEXTVAL, 'Rockstar Games');
INSERT INTO desarrolladores (desarrollador_id, nombre_desarrollador) VALUES (seq_desarrolladores.NEXTVAL, 'Naughty Dog');
INSERT INTO desarrolladores (desarrollador_id, nombre_desarrollador) VALUES (seq_desarrolladores.NEXTVAL, 'FromSoftware');
INSERT INTO desarrolladores (desarrollador_id, nombre_desarrollador) VALUES (seq_desarrolladores.NEXTVAL, 'Nintendo');
INSERT INTO desarrolladores (desarrollador_id, nombre_desarrollador) VALUES (seq_desarrolladores.NEXTVAL, 'EA Sports');

-- Insertar Videojuegos
INSERT INTO videojuegos (videojuego_id, titulo, descripcion, fecha_lanzamiento, precio, stock, genero_id, plataforma_id, desarrollador_id) VALUES (seq_videojuegos.NEXTVAL, 'The Witcher 3: Wild Hunt', 'Un juego de rol de mundo abierto.', TO_DATE('2015-05-19', 'YYYY-MM-DD'), 39.99, 150, 3, 1, 1);
INSERT INTO videojuegos (videojuego_id, titulo, descripcion, fecha_lanzamiento, precio, stock, genero_id, plataforma_id, desarrollador_id) VALUES (seq_videojuegos.NEXTVAL, 'Red Dead Redemption 2', 'Una épica historia del oeste americano.', TO_DATE('2018-10-26', 'YYYY-MM-DD'), 49.99, 120, 2, 2, 2);
INSERT INTO videojuegos (videojuego_id, titulo, descripcion, fecha_lanzamiento, precio, stock, genero_id, plataforma_id, desarrollador_id) VALUES (seq_videojuegos.NEXTVAL, 'The Last of Us Part II', 'Una intensa aventura post-apocalíptica.', TO_DATE('2020-06-19', 'YYYY-MM-DD'), 59.99, 200, 1, 2, 3);
INSERT INTO videojuegos (videojuego_id, titulo, descripcion, fecha_lanzamiento, precio, stock, genero_id, plataforma_id, desarrollador_id) VALUES (seq_videojuegos.NEXTVAL, 'Elden Ring', 'Un desafiante RPG de acción.', TO_DATE('2022-02-25', 'YYYY-MM-DD'), 69.99, 300, 3, 3, 4);
INSERT INTO videojuegos (videojuego_id, titulo, descripcion, fecha_lanzamiento, precio, stock, genero_id, plataforma_id, desarrollador_id) VALUES (seq_videojuegos.NEXTVAL, 'The Legend of Zelda: Breath of the Wild', 'Explora el vasto reino de Hyrule.', TO_DATE('2017-03-03', 'YYYY-MM-DD'), 59.99, 250, 2, 4, 5);
INSERT INTO videojuegos (videojuego_id, titulo, descripcion, fecha_lanzamiento, precio, stock, genero_id, plataforma_id, desarrollador_id) VALUES (seq_videojuegos.NEXTVAL, 'FIFA 23', 'El simulador de fútbol más popular.', TO_DATE('2022-09-27', 'YYYY-MM-DD'), 49.99, 400, 5, 1, 6);

-- Insertar Clientes (más de 100 para un buen volumen de datos)
DECLARE
BEGIN
    FOR i IN 1..150 LOOP
        INSERT INTO clientes (cliente_id, nombre, apellido, email, fecha_registro, telefono)
        VALUES (
            seq_clientes.NEXTVAL,
            'Nombre' || i,
            'Apellido' || i,
            'cliente' || i || '@email.com',
            SYSDATE - DBMS_RANDOM.VALUE(1, 365),
            '9' || TRUNC(DBMS_RANDOM.VALUE(10000000, 99999999))
        );
    END LOOP;
    COMMIT;
END;
/

-- Insertar Ventas y Detalles de Venta (más de 100 ventas)
DECLARE
    v_total_venta NUMBER;
    v_cliente_id NUMBER;
    v_videojuego_id NUMBER;
    v_cantidad NUMBER;
    v_precio NUMBER;
BEGIN
    FOR i IN 1..200 LOOP
        -- Seleccionar un cliente al azar
        SELECT cliente_id INTO v_cliente_id FROM (SELECT cliente_id FROM clientes ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1;

        -- Insertar la cabecera de la venta
        INSERT INTO ventas (venta_id, cliente_id, total_venta) VALUES (seq_ventas.NEXTVAL, v_cliente_id, 0) RETURNING venta_id INTO v_total_venta;

        -- Variable para el total de la venta
        v_total_venta := 0;

        -- Insertar entre 1 y 3 detalles por venta
        FOR j IN 1..TRUNC(DBMS_RANDOM.VALUE(1, 4)) LOOP
            -- Seleccionar un videojuego al azar
            SELECT videojuego_id, precio INTO v_videojuego_id, v_precio FROM (SELECT videojuego_id, precio FROM videojuegos ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1;
            
            -- Cantidad aleatoria
            v_cantidad := TRUNC(DBMS_RANDOM.VALUE(1, 3));

            -- Insertar el detalle de la venta
            INSERT INTO detalles_venta (detalle_id, venta_id, videojuego_id, cantidad, precio_unitario)
            VALUES (seq_detalles_venta.NEXTVAL, seq_ventas.CURRVAL, v_videojuego_id, v_cantidad, v_precio);
            
            -- Actualizar el stock del videojuego
            UPDATE videojuegos SET stock = stock - v_cantidad WHERE videojuego_id = v_videojuego_id;

            -- Acumular el total de la venta
            v_total_venta := v_total_venta + (v_cantidad * v_precio);
        END LOOP;
        
        -- Actualizar el total en la tabla de ventas
        UPDATE ventas SET total_venta = v_total_venta WHERE venta_id = seq_ventas.CURRVAL;
    END LOOP;
    COMMIT;
END;
/