CREATE OR REPLACE PACKAGE PKG_CLIENTES AS

    /**
        Función pública: Calcula y devuelve la categoría de un cliente 
        (Bronce, Plata, Oro) basado en el total de sus compras.
        (Función con parámetros)
    */
    FUNCTION FN_CATEGORIZAR_CLIENTE(
        p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
    ) RETURN VARCHAR2;

    /*
        Procedimiento público: Imprime en consola un informe detallado
        de un cliente, incluyendo sus datos y su historial de ventas.
        (Procedimiento con parámetros)
    */
    PROCEDURE SP_GENERAR_INFORME_CLIENTE(
        p_cliente_id IN CLIENTE.CLIENTE_ID%TYPE
    );

END PKG_CLIENTES;