/*
FN_TOTAL_VENTAS_TIENDA (sin parámetros) demuestra el procesamiento de información masiva (toda la tabla VENTA) 
y puede ser usada directamente en sentencias SQL para reportes rápidos 
(Ej: SELECT FN_TOTAL_VENTAS_TIENDA() FROM DUAL;).
*/
CREATE OR REPLACE FUNCTION FN_TOTAL_VENTAS_TIENDA
RETURN NUMBER
IS
    v_total_general NUMBER;
BEGIN
    -- Esta función no necesita parámetros
    -- Procesa información masiva (toda la tabla VENTA)
    SELECT SUM(TOTAL_VENTA)
    INTO v_total_general
    FROM VENTA;
    
    RETURN NVL(v_total_general, 0);
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1; -- Retorna -1 para indicar un error
END;
/