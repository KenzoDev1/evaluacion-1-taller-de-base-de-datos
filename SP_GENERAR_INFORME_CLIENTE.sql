--Record almacinar cliente
CREATE OR REPLACE TYPE REC_CLIENTE AS OBJECT(
    CLIENTE_ID NUMBER,
    NOMBRE VARCHAR2(50),
    APELLIDO VARCHAR2(50),
    EMAIL VARCHAR2(100),
    FECHA_REGISTRO DATE,
    TELEFONO VARCHAR2(15)
);

/

--Record para venta
CREATE OR REPLACE TYPE REC_VENTA AS OBJECT(
    VENTA_ID NUMBER,
    FECHA_VENTA TIMESTAMP(6),
    TOTAL_VENTA NUMBER(10,2)
);

/

--Varray de ventas
CREATE OR REPLACE TYPE AR_VENTAS AS VARRAY(200) OF REC_VENTA;

/

--Procedimiento
CREATE OR REPLACE PROCEDURE SP_GENERAR_INFORME_CLIENTE(
    p_cliente_id IN cliente.cliente_id%TYPE
) IS
    -- Variables RECORD
    v_cliente REC_CLIENTE;
    
    -- VARRAY
    v_ventas AR_VENTAS := AR_VENTAS();
    
    -- Cursor para obtener datos del cliente
    CURSOR cur_cliente IS
        SELECT REC_CLIENTE(cliente_id, nombre, apellido , email, fecha_registro, telefono)
        FROM cliente
        WHERE cliente_id = p_cliente_id;
    
    -- Cursor para obtener ventas de ese cliente
    CURSOR cur_ventas IS
        SELECT venta_id, FECHA_VENTA, TOTAL_VENTA
        FROM venta
        WHERE cliente_id = p_cliente_id;
    
    -- Variable para categoría
    v_categoria VARCHAR2(30);
BEGIN
    -- 1. Obtener datos del cliente
    OPEN cur_cliente;
    FETCH cur_cliente INTO v_cliente;
    CLOSE cur_cliente;

    -- 2. Obtener ventas y llenar el VARRAY
    FOR rec_ventas IN cur_ventas LOOP
        v_ventas.EXTEND;
        v_ventas(v_ventas.COUNT) := REC_VENTA(rec_ventas.venta_id, rec_ventas.fecha_venta, rec_ventas.total_venta);
    END LOOP;

    -- 3. Categoría usando la función
    v_categoria := fn_categorizar_cliente(p_cliente_id);

    -- 4. Imprimir informe
    DBMS_OUTPUT.PUT_LINE('===== INFORME CLIENTE =====');
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_cliente.cliente_id);
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_cliente.nombre || ' ' || v_cliente.apellido);
    DBMS_OUTPUT.PUT_LINE('Email: ' || v_cliente.email);
    DBMS_OUTPUT.PUT_LINE('Categoría: ' || v_categoria);
    DBMS_OUTPUT.PUT_LINE('--- Ventas ---');

    IF v_ventas.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Este cliente no tiene ventas registradas.');
    ELSE
        FOR i IN 1..v_ventas.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Venta ' || v_ventas(i).venta_id ||
                ' | Fecha: ' || v_ventas(i).fecha_venta ||
                ' | Monto: ' || v_ventas(i).total_venta
            );
        END LOOP;
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: El cliente con ID ' || p_cliente_id || ' no existe.');
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Hay múltiples registros para el cliente con ID ' || p_cliente_id || '.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR inesperado: ' || SQLERRM);
END;

/

SET SERVEROUTPUT ON;
EXEC SP_GENERAR_INFORME_CLIENTE(1);
