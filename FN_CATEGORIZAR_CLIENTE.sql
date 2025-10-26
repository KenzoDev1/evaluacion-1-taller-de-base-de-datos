/*
 FN_CATEGORIZAR_CLIENTE (con parámetros) permite procesar la información de un cliente específico. 
 Es reutilizable y esencial para el informe de cliente y el programa de fidelización.
*/
CREATE OR REPLACE FUNCTION FN_CATEGORIZAR_CLIENTE(
    p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
) 
RETURN VARCHAR2
IS 
    v_total_gastado NUMBER;
    v_categoria     VARCHAR2(20);
BEGIN
    -- Primero, calculamos el total gastado por el cliente
    -- Sumamos el total de todas sus ventas
    SELECT SUM(TOTAL_VENTA)
    INTO v_total_gastado
    FROM VENTA
    WHERE CLIENTE_ID = p_cliente_id;

    -- Si no ha comprado nada, el total será NULL. Lo manejamos.
    IF v_total_gastado IS NULL OR v_total_gastado = 0 THEN
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
    -- Manejamos el caso de que el cliente no exista
    WHEN NO_DATA_FOUND THEN
        -- Aunque un SUM(NULL) devuelve NULL (manejado arriba),
        -- es buena práctica mantener la excepción por si se cambia la lógica.
        RETURN 'CLIENTE INEXISTENTE';
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END;
/