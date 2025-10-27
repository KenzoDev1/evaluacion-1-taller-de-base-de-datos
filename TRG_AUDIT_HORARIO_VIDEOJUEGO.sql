/* 
trigger que impide realizar cambios en la tabla VIDEOJUEGO (como cambios de precio o stock) 
fuera del horario laboral (ej. 9:00 a 18:00 de Lunes a Viernes). 
*/
CREATE OR REPLACE TRIGGER TRG_AUDIT_HORARIO_VIDEOJUEGO
BEFORE INSERT OR UPDATE OR DELETE ON VIDEOJUEGO
-- NOTA: No se incluye "FOR EACH ROW", por lo tanto,
-- es un trigger a NIVEL DE SENTENCIA (Statement-Level)
DECLARE
    v_hora NUMBER;
    v_dia  NUMBER;
BEGIN
    -- Obtenemos la hora actual (formato 24h) y el día de la semana
    v_hora := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));
    v_dia  := TO_NUMBER(TO_CHAR(SYSDATE, 'D')); -- 1=Domingo, 7=Sábado (en config. USA)

    -- Validamos horario laboral (Lunes a Viernes de 9 a 18)
    -- Asumimos Lunes=2, Viernes=6
    IF v_dia BETWEEN 2 AND 6 THEN
        -- Es día de semana, validamos la hora
        IF v_hora < 9 OR v_hora >= 18 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No se pueden modificar videojuegos fuera de horario laboral (9:00-18:00).');
        END IF;
    ELSE
        -- Es fin de semana
        RAISE_APPLICATION_ERROR(-20002, 'No se pueden modificar videojuegos durante el fin de semana.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Relanzamos el error para detener la transacción
        RAISE;
END;