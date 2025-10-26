CREATE OR REPLACE PACKAGE BODY PKG_CLIENTES AS

    /**
     * Función PRIVADA: No está en la SPEC.
     * Calcula el monto total gastado por un cliente.
     * Se usa internamente para mantener la lógica de cálculo oculta.
     */
    FUNCTION FN_CALCULAR_TOTAL_COMPRADO(
        p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
    ) RETURN NUMBER
    IS
        v_total_gastado NUMBER;
    BEGIN
        SELECT SUM(TOTAL_VENTA)
        INTO v_total_gastado
        FROM VENTA
        WHERE CLIENTE_ID = p_cliente_id;
        
        RETURN NVL(v_total_gastado, 0);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;

    --- Implementación de Funciones Públicas ---

    FUNCTION FN_CATEGORIZAR_CLIENTE(
        p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
    ) RETURN VARCHAR2
    IS 
        v_total_gastado NUMBER;
        v_categoria     VARCHAR2(20);
    BEGIN
        -- 1. Llama a la función PRIVADA
        v_total_gastado := FN_CALCULAR_TOTAL_COMPRADO(p_cliente_id);

        -- 2. Aplica la lógica de negocio
        IF v_total_gastado = 0 THEN
            v_categoria := 'SIN CATEGORIA';
        ELSIF v_total_gastado <= 100 THEN
            v_categoria := 'BRONCE';
        ELSIF v_total_gastado <= 300 THEN
            v_categoria := 'PLATA';
        ELSE
            v_categoria := 'ORO';
        END IF;

        RETURN v_categoria;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'ERROR: ' || SQLERRM;
    END FN_CATEGORIZAR_CLIENTE;


    --- Implementación de Procedimientos Públicos ---

    PROCEDURE SP_GENERAR_INFORME_CLIENTE(
        p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
    ) IS
        -- Variables, cursores y tipos (basado en tu SP_GENERAR_INFORME_CLIENTE.sql)
        CURSOR cur_cliente IS
            SELECT NOMBRE, APELLIDO, EMAIL, FECHA_REGISTRO
            FROM CLIENTE
            WHERE CLIENTE_ID = p_cliente_id;
            
        CURSOR cur_ventas IS
            SELECT VENTA_ID, FECHA_VENTA, TOTAL_VENTA
            FROM VENTA
            WHERE CLIENTE_ID = p_cliente_id
            ORDER BY FECHA_VENTA DESC;

        rec_cliente cur_cliente%ROWTYPE;
        v_categoria VARCHAR2(30);
        v_ventas_count NUMBER := 0;
        
    BEGIN
        -- 1. Obtener datos del cliente
        OPEN cur_cliente;
        FETCH cur_cliente INTO rec_cliente;
        
        IF cur_cliente%NOTFOUND THEN
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE cur_cliente;

        -- 2. Obtener categoría llamando a la FUNCIÓN DEL PACKAGE
        v_categoria := PKG_CLIENTES.FN_CATEGORIZAR_CLIENTE(p_cliente_id);

        -- 3. Imprimir informe
        DBMS_OUTPUT.PUT_LINE('===== INFORME DE CLIENTE "CHILEGAMES" =====');
        DBMS_OUTPUT.PUT_LINE('ID Cliente: ' || p_cliente_id);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || rec_cliente.NOMBRE || ' ' || rec_cliente.APELLIDO);
        DBMS_OUTPUT.PUT_LINE('Email: ' || rec_cliente.EMAIL);
        DBMS_OUTPUT.PUT_LINE('Cliente desde: ' || TO_CHAR(rec_cliente.FECHA_REGISTRO, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('Categoría Fidelización: ' || v_categoria);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('--- Historial de Ventas ---');

        FOR rec_venta IN cur_ventas LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Venta ID: ' || rec_venta.VENTA_ID ||
                ' | Fecha: ' || TO_CHAR(rec_venta.FECHA_VENTA, 'DD/MM/YYYY HH24:MI') ||
                ' | Monto: $' || rec_venta.TOTAL_VENTA
            );
            v_ventas_count := v_ventas_count + 1;
        END LOOP;

        IF v_ventas_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('El cliente no tiene ventas registradas.');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('=============================================');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: El cliente con ID ' || p_cliente_id || ' no existe.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR inesperado: ' || SQLERRM);
    END SP_GENERAR_INFORME_CLIENTE;

END PKG_CLIENTES;
/