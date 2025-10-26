/*
SP_RECALCULAR_TOTALES_VENTA (sin parámetros) 
es un procedimiento de mantenimiento que procesa información masiva. 
Asegura la integridad de los datos recorriendo toda la tabla VENTA y DETALLE_VENTA para sincronizar los totales.
*/
CREATE OR REPLACE PROCEDURE SP_RECALCULAR_TOTALES_VENTA
IS
    v_nuevo_total NUMBER;

    -- Cursor para procesar de forma masiva TODAS las ventas
    CURSOR cur_ventas IS
        SELECT VENTA_ID FROM VENTA;
        
BEGIN
    FOR reg_venta IN cur_ventas LOOP
        -- 1. Calculamos el total real sumando los detalles
        SELECT SUM(CANTIDAD * PRECIO_UNITARIO)
        INTO v_nuevo_total
        FROM DETALLE_VENTA
        WHERE VENTA_ID = reg_venta.VENTA_ID;
        
        -- 2. Actualizamos la tabla VENTA con el total correcto
        UPDATE VENTA
        SET TOTAL_VENTA = NVL(v_nuevo_total, 0)
        WHERE VENTA_ID = reg_venta.VENTA_ID;
        
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Procesamiento masivo de totales de venta completado.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en procesamiento masivo: ' || SQLERRM);
END;
/