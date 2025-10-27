CREATE OR REPLACE PACKAGE BODY PKG_CLIENTES AS

    -- ======================================================================
    -- ELEMENTOS PRIVADOS
    -- ======================================================================
    FUNCTION FN_CALCULAR_TOTAL_COMPRADO(
        p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
    ) RETURN NUMBER
    IS
        v_total_gastado NUMBER;
    BEGIN
        SELECT SUM(TOTAL_VENTA) INTO v_total_gastado
        FROM VENTA WHERE CLIENTE_ID = p_cliente_id;
        RETURN NVL(v_total_gastado, 0);
    EXCEPTION WHEN OTHERS THEN RETURN 0;
    END FN_CALCULAR_TOTAL_COMPRADO;

    -- ======================================================================
    -- IMPLEMENTACIÓN PÚBLICA
    -- ======================================================================

    FUNCTION FN_CATEGORIZAR_CLIENTE(
        p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
    ) RETURN VARCHAR2
    IS
        v_total_gastado NUMBER;
        v_categoria     VARCHAR2(20);
    BEGIN
        v_total_gastado := FN_CALCULAR_TOTAL_COMPRADO(p_cliente_id);
        IF v_total_gastado = 0 THEN v_categoria := 'SIN CATEGORIA';
        ELSIF v_total_gastado <= 100 THEN v_categoria := 'BRONCE';
        ELSIF v_total_gastado <= 300 THEN v_categoria := 'PLATA';
        ELSE v_categoria := 'ORO';
        END IF;
        RETURN v_categoria;
    EXCEPTION WHEN OTHERS THEN RETURN 'ERROR: ' || SQLERRM;
    END FN_CATEGORIZAR_CLIENTE;


    PROCEDURE SP_GENERAR_INFORME_CLIENTE(
        p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
    ) IS
        CURSOR cur_cliente IS
            SELECT NOMBRE, APELLIDO, EMAIL, FECHA_REGISTRO
            FROM CLIENTE WHERE CLIENTE_ID = p_cliente_id;

        CURSOR cur_ventas (cp_cliente_id CLIENTE.CLIENTE_ID%TYPE) IS
            SELECT VENTA_ID, FECHA_VENTA, TOTAL_VENTA
            FROM VENTA WHERE CLIENTE_ID = cp_cliente_id
            ORDER BY FECHA_VENTA DESC;

        rec_cliente cur_cliente%ROWTYPE;

        -- VARRAY EXTERNO (AR_VENTAS)
        v_ventas AR_VENTAS := AR_VENTAS();

        temp_rec_venta REC_VENTA := REC_VENTA(NULL, NULL, NULL); -- Inicializa con NULLs

        v_categoria VARCHAR2(30);

        e_cliente_sin_ventas EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_cliente_sin_ventas, -20003);

    BEGIN
        OPEN cur_cliente;
        FETCH cur_cliente INTO rec_cliente;
        IF cur_cliente%NOTFOUND THEN CLOSE cur_cliente; RAISE NO_DATA_FOUND; END IF;
        CLOSE cur_cliente;

        v_categoria := PKG_CLIENTES.FN_CATEGORIZAR_CLIENTE(p_cliente_id);

        DBMS_OUTPUT.PUT_LINE('===== INFORME DE CLIENTE "CHILEGAMES" =====');
        DBMS_OUTPUT.PUT_LINE('ID Cliente: ' || p_cliente_id);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || rec_cliente.NOMBRE || ' ' || rec_cliente.APELLIDO);
        DBMS_OUTPUT.PUT_LINE('Email: ' || rec_cliente.EMAIL);
        DBMS_OUTPUT.PUT_LINE('Cliente desde: ' || TO_CHAR(rec_cliente.FECHA_REGISTRO, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('Categoría Fidelización: ' || v_categoria);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('--- Historial de Ventas ---');

        -- Llenar el VARRAY externo v_ventas (Asignando atributos)
        FOR rec_venta IN cur_ventas(p_cliente_id) LOOP
            v_ventas.EXTEND; -- Extiende el VARRAY

            temp_rec_venta.VENTA_ID    := rec_venta.VENTA_ID;
            temp_rec_venta.FECHA_VENTA := rec_venta.FECHA_VENTA;
            temp_rec_venta.TOTAL_VENTA := rec_venta.TOTAL_VENTA;

            -- Asigna el objeto temporal ya poblado al VARRAY
            v_ventas(v_ventas.LAST) := temp_rec_venta;

        END LOOP;

        -- Verificar si hubo ventas
        IF v_ventas.COUNT = 0 THEN
            RAISE e_cliente_sin_ventas;
        END IF;

        -- Imprimir las ventas iterando sobre el VARRAY externo
        FOR i IN 1..v_ventas.COUNT LOOP
             DBMS_OUTPUT.PUT_LINE(
                'Venta ID: ' || v_ventas(i).VENTA_ID ||
                ' | Fecha: ' || TO_CHAR(v_ventas(i).FECHA_VENTA, 'DD/MM/YYYY HH24:MI') ||
                ' | Monto: $' || v_ventas(i).TOTAL_VENTA
            );
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('=============================================');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: El cliente con ID ' || p_cliente_id || ' no existe.');
        WHEN e_cliente_sin_ventas THEN
            DBMS_OUTPUT.PUT_LINE('AVISO: El cliente existe pero no tiene ventas registradas.');
            DBMS_OUTPUT.PUT_LINE('=============================================');
        WHEN OTHERS THEN
             IF cur_cliente%ISOPEN THEN CLOSE cur_cliente; END IF;
            DBMS_OUTPUT.PUT_LINE('ERROR inesperado: ' || SQLCODE || ' - ' || SQLERRM);
    END SP_GENERAR_INFORME_CLIENTE;

END PKG_CLIENTES;