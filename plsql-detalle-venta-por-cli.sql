SET SERVEROUTPUT ON;

/*
Este bloque PL/SQL muestra todos los detalles venta, de un cliente ingresado en el parametro
*/

BEGIN
   EXECUTE IMMEDIATE 'DROP TYPE varray_ventas_t';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4043 THEN
         RAISE;
      END IF;
END;
/

-- Luego se elimina el RECORD base
BEGIN
   EXECUTE IMMEDIATE 'DROP TYPE rec_detalle_venta_t';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -4043 THEN
         RAISE;
      END IF;
END;
/

-- Se crea un record de detalle venta, realiza una funcion de molde para la creacion del varray
CREATE OR REPLACE TYPE rec_detalle_venta_t AS OBJECT (
    detalle_id NUMBER,
    venta_id NUMBER,
    videojuego_id NUMBER,
    cantidad NUMBER(3),
    precio_unitario NUMBER(8,2)
);
/


CREATE OR REPLACE TYPE varray_ventas_t AS VARRAY(100) OF rec_detalle_venta_t;
/

DECLARE

v_cliente_id cliente.cliente_id%TYPE := 50;

historial_compras varray_ventas_t := varray_ventas_t();

CURSOR cur_detalle_venta(p_cli_id cliente.cliente_id%TYPE) IS
SELECT dv.detalle_id,
dv.venta_id,
dv.videojuego_id,
dv.cantidad,
dv.precio_unitario
FROM detalle_venta dv
INNER JOIN venta v ON (dv.venta_id=v.venta_id)
WHERE v.cliente_id=p_cli_id;

BEGIN

-- Se agregan los records al VARRAY segun la restriccion del ID del cliente
FOR rec_detalle_venta IN cur_detalle_venta(v_cliente_id) LOOP
    -- Se realiza un espacio en el VARRAY
    historial_compras.EXTEND;
    -- Se modifica el espacio del VARRAY
    -- Importante notar que estamos ocupando el molde del record para modificar este espacio en el VARRAY
    -- hay que notar que tiene la t al final, refiriendose a "TYPE" y dentro de este molde/RECORD
    -- ocupamos los datos que nos da el RECORD implicito
    historial_compras(historial_compras.LAST) := rec_detalle_venta_t(
        rec_detalle_venta.detalle_id,
        rec_detalle_venta.venta_id,
        rec_detalle_venta.videojuego_id,
        rec_detalle_venta.cantidad,
        rec_detalle_venta.precio_unitario
    );
END LOOP;

-- En Oracle SQL, para indexar una lista, empieza desde el 1 y no desde el 0
FOR i IN 1..historial_compras.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('=============================================');
    DBMS_OUTPUT.PUT_LINE('Detalle ID: '||historial_compras(i).detalle_id);
    DBMS_OUTPUT.PUT_LINE('Venta ID: '||historial_compras(i).venta_id);
    DBMS_OUTPUT.PUT_LINE('Videojuego ID: '||historial_compras(i).videojuego_id);
    DBMS_OUTPUT.PUT_LINE('Cantidad: '||historial_compras(i).cantidad);
    DBMS_OUTPUT.PUT_LINE('Precio unitario: '||historial_compras(i).precio_unitario);
    DBMS_OUTPUT.PUT_LINE('=============================================');
END LOOP;

END;
/