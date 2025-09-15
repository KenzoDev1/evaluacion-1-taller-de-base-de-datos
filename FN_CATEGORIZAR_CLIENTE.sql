/*
La función `FN_CATEGORIZAR_CLIENTE` recibe como parámetro el identificador de un cliente y 
consulta la base de datos para contar cuántas ventas tiene registradas en las tablas `VENTA` y `DETALLE_VENTA`.
Con ese resultado, aplica una lógica de clasificación: si el cliente tiene más de una venta se categoriza como *CLIENTE FRECUENTE*,
de lo contrario se clasifica como *CLIENTE OCASIONAL*. Finalmente, devuelve esa categoría como un valor de tipo `VARCHAR2`,
permitiendo usarla en consultas o informes para identificar rápidamente el nivel de actividad de cada cliente.
*/

CREATE OR REPLACE FUNCTION FN_CATEGORIZAR_CLIENTE(id_cliente IN CLIENTE.CLIENTE_ID%TYPE) 
RETURN VARCHAR2
IS 
V_CATEGORIA VARCHAR2(20);
V_TOTAL NUMBER;
BEGIN

    SELECT COUNT(DV.VENTA_ID)
    INTO V_TOTAL
    FROM DETALLE_VENTA DV
    JOIN VENTA V ON (V.VENTA_ID = DV.VENTA_ID)
    JOIN CLIENTE C ON (C.CLIENTE_ID = V.CLIENTE_ID)

    WHERE C.CLIENTE_ID = id_cliente;
    
    IF V_TOTAL > 2 THEN
        V_CATEGORIA := 'CLIENTE FRECUENTE';
    ELSE
        V_CATEGORIA := 'CLIENTE OCASIONAL';
    END IF;

    RETURN V_CATEGORIA;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'CLIENTE INEXISTENTE';
    WHEN TOO_MANY_ROWS THEN
        RETURN 'ERROR: CLIENTE DUPLICADO';
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
        

END;

/

SELECT fn_categorizar_cliente(1) AS CATEGORIA FROM dual;