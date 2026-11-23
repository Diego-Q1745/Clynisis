-- ============================================================
-- CLINISYS - SISTEMA DE GESTION DE CLINICA
-- FASE 2: CONSULTAS, REPORTES, REGLAS Y PRUEBAS FINALES
-- Motor: MySQL 8.0.16 o superior
--
-- IMPORTANTE:
-- 1. Este archivo CONTINUA la base de datos creada en los pasos 1-4.
-- 2. No elimina tablas ni datos.
-- 3. Ejecutar despues de crear las 7 tablas e insertar los 64 registros.
-- 4. Los datos de prueba son ficticios.
-- ============================================================

USE CLINISYS_DB;

-- ============================================================
-- PASO 5: VISTAS Y CONSULTAS SQL REUTILIZABLES
-- ============================================================

-- 5.1 Vista: citas con datos de paciente, medico y especialidad.
CREATE OR REPLACE VIEW vw_citas_detalladas AS
SELECT
    c.id_cita,
    c.fecha_hora,
    c.duracion_minutos,
    c.motivo,
    c.costo_total,
    c.estado_cita,
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellidos) AS paciente,
    p.numero_documento AS documento_paciente,
    m.id_medico,
    CONCAT(m.nombres, ' ', m.apellidos) AS medico,
    e.nombre AS especialidad,
    c.observaciones
FROM citas c
INNER JOIN pacientes p
    ON c.id_paciente = p.id_paciente
INNER JOIN medicos m
    ON c.id_medico = m.id_medico
INNER JOIN especialidades e
    ON c.id_especialidad = e.id_especialidad;


-- 5.2 Vista: historial de atenciones de los pacientes.
CREATE OR REPLACE VIEW vw_historial_pacientes AS
SELECT
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellidos) AS paciente,
    c.id_cita,
    c.fecha_hora,
    c.estado_cita,
    CONCAT(m.nombres, ' ', m.apellidos) AS medico,
    e.nombre AS especialidad,
    co.fecha_consulta,
    co.diagnostico,
    co.tratamiento,
    co.recomendaciones
FROM pacientes p
INNER JOIN citas c
    ON p.id_paciente = c.id_paciente
INNER JOIN medicos m
    ON c.id_medico = m.id_medico
INNER JOIN especialidades e
    ON c.id_especialidad = e.id_especialidad
LEFT JOIN consultas co
    ON c.id_cita = co.id_cita;


-- 5.3 Vista: pagos, total abonado y saldo pendiente por cita.
CREATE OR REPLACE VIEW vw_estado_pagos AS
SELECT
    c.id_cita,
    c.costo_total,
    COALESCE(
        SUM(
            CASE
                WHEN pg.estado_pago = 'CONFIRMADO' THEN pg.monto
                ELSE 0
            END
        ), 0
    ) AS total_pagado,
    GREATEST(
        c.costo_total - COALESCE(
            SUM(
                CASE
                    WHEN pg.estado_pago = 'CONFIRMADO' THEN pg.monto
                    ELSE 0
                END
            ), 0
        ), 0
    ) AS saldo_pendiente,
    CASE
        WHEN c.costo_total = 0 THEN 'SIN_CARGO'
        WHEN COALESCE(
            SUM(
                CASE
                    WHEN pg.estado_pago = 'CONFIRMADO' THEN pg.monto
                    ELSE 0
                END
            ), 0
        ) >= c.costo_total THEN 'PAGADA'
        WHEN COALESCE(
            SUM(
                CASE
                    WHEN pg.estado_pago = 'CONFIRMADO' THEN pg.monto
                    ELSE 0
                END
            ), 0
        ) = 0 THEN 'SIN_PAGOS'
        ELSE 'PARCIAL'
    END AS estado_financiero
FROM citas c
LEFT JOIN pagos pg
    ON c.id_cita = pg.id_cita
GROUP BY c.id_cita, c.costo_total;


-- 5.4 Vista: ingresos agrupados por mes.
CREATE OR REPLACE VIEW vw_ingresos_mensuales AS
SELECT
    DATE_FORMAT(fecha_pago, '%Y-%m') AS periodo,
    COUNT(*) AS cantidad_pagos,
    SUM(monto) AS ingresos_confirmados
FROM pagos
WHERE estado_pago = 'CONFIRMADO'
GROUP BY DATE_FORMAT(fecha_pago, '%Y-%m');


-- 5.5 Vista: resumen de citas por medico.
CREATE OR REPLACE VIEW vw_resumen_medicos AS
SELECT
    m.id_medico,
    CONCAT(m.nombres, ' ', m.apellidos) AS medico,
    COUNT(c.id_cita) AS total_citas,
    SUM(CASE WHEN c.estado_cita = 'ATENDIDA' THEN 1 ELSE 0 END) AS citas_atendidas,
    SUM(CASE WHEN c.estado_cita = 'PROGRAMADA' THEN 1 ELSE 0 END) AS citas_programadas,
    SUM(CASE WHEN c.estado_cita = 'CONFIRMADA' THEN 1 ELSE 0 END) AS citas_confirmadas,
    SUM(CASE WHEN c.estado_cita = 'CANCELADA' THEN 1 ELSE 0 END) AS citas_canceladas,
    SUM(CASE WHEN c.estado_cita = 'NO_ASISTIO' THEN 1 ELSE 0 END) AS inasistencias
FROM medicos m
LEFT JOIN citas c
    ON m.id_medico = c.id_medico
GROUP BY m.id_medico, m.nombres, m.apellidos;


-- ============================================================
-- PASO 6: REGLAS DE NEGOCIO AUTOMATIZADAS CON TRIGGERS
-- ============================================================

-- 6.1 Evitar citas superpuestas para un mismo medico al insertar.
DROP TRIGGER IF EXISTS trg_citas_validar_horario_insert;

DELIMITER $$

CREATE TRIGGER trg_citas_validar_horario_insert
BEFORE INSERT ON citas
FOR EACH ROW
BEGIN
    DECLARE v_conflictos INT DEFAULT 0;

    IF NEW.estado_cita NOT IN ('CANCELADA', 'NO_ASISTIO') THEN
        SELECT COUNT(*)
        INTO v_conflictos
        FROM citas c
        WHERE c.id_medico = NEW.id_medico
          AND c.estado_cita NOT IN ('CANCELADA', 'NO_ASISTIO')
          AND NEW.fecha_hora < DATE_ADD(
              c.fecha_hora, INTERVAL c.duracion_minutos MINUTE
          )
          AND DATE_ADD(
              NEW.fecha_hora, INTERVAL NEW.duracion_minutos MINUTE
          ) > c.fecha_hora;

        IF v_conflictos > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El medico ya tiene una cita en ese horario.';
        END IF;
    END IF;
END$$

-- 6.2 Evitar citas superpuestas al actualizar una cita.
DROP TRIGGER IF EXISTS trg_citas_validar_horario_update;

CREATE TRIGGER trg_citas_validar_horario_update
BEFORE UPDATE ON citas
FOR EACH ROW
BEGIN
    DECLARE v_conflictos INT DEFAULT 0;

    IF NEW.estado_cita NOT IN ('CANCELADA', 'NO_ASISTIO') THEN
        SELECT COUNT(*)
        INTO v_conflictos
        FROM citas c
        WHERE c.id_medico = NEW.id_medico
          AND c.id_cita <> OLD.id_cita
          AND c.estado_cita NOT IN ('CANCELADA', 'NO_ASISTIO')
          AND NEW.fecha_hora < DATE_ADD(
              c.fecha_hora, INTERVAL c.duracion_minutos MINUTE
          )
          AND DATE_ADD(
              NEW.fecha_hora, INTERVAL NEW.duracion_minutos MINUTE
          ) > c.fecha_hora;

        IF v_conflictos > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El medico ya tiene una cita en ese horario.';
        END IF;
    END IF;
END$$

-- 6.3 Evitar que los pagos confirmados superen el costo de la cita.
DROP TRIGGER IF EXISTS trg_pagos_validar_insert;

CREATE TRIGGER trg_pagos_validar_insert
BEFORE INSERT ON pagos
FOR EACH ROW
BEGIN
    DECLARE v_costo DECIMAL(10,2);
    DECLARE v_pagado DECIMAL(10,2) DEFAULT 0;

    IF NEW.estado_pago = 'CONFIRMADO' THEN
        SELECT costo_total
        INTO v_costo
        FROM citas
        WHERE id_cita = NEW.id_cita;

        SELECT COALESCE(SUM(monto), 0)
        INTO v_pagado
        FROM pagos
        WHERE id_cita = NEW.id_cita
          AND estado_pago = 'CONFIRMADO';

        IF v_pagado + NEW.monto > v_costo THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El pago supera el saldo pendiente de la cita.';
        END IF;
    END IF;
END$$

-- 6.4 Validar el total de pagos al modificar un pago.
DROP TRIGGER IF EXISTS trg_pagos_validar_update;

CREATE TRIGGER trg_pagos_validar_update
BEFORE UPDATE ON pagos
FOR EACH ROW
BEGIN
    DECLARE v_costo DECIMAL(10,2);
    DECLARE v_pagado DECIMAL(10,2) DEFAULT 0;

    IF NEW.estado_pago = 'CONFIRMADO' THEN
        SELECT costo_total
        INTO v_costo
        FROM citas
        WHERE id_cita = NEW.id_cita;

        SELECT COALESCE(SUM(monto), 0)
        INTO v_pagado
        FROM pagos
        WHERE id_cita = NEW.id_cita
          AND estado_pago = 'CONFIRMADO'
          AND id_pago <> OLD.id_pago;

        IF v_pagado + NEW.monto > v_costo THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El pago actualizado supera el saldo pendiente de la cita.';
        END IF;
    END IF;
END$$

-- 6.5 Evitar reducir el costo de una cita por debajo de lo ya pagado.
DROP TRIGGER IF EXISTS trg_citas_validar_costo_update;

CREATE TRIGGER trg_citas_validar_costo_update
BEFORE UPDATE ON citas
FOR EACH ROW
BEGIN
    DECLARE v_pagado DECIMAL(10,2) DEFAULT 0;

    SELECT COALESCE(SUM(monto), 0)
    INTO v_pagado
    FROM pagos
    WHERE id_cita = OLD.id_cita
      AND estado_pago = 'CONFIRMADO';

    IF NEW.costo_total < v_pagado THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nuevo costo no puede ser menor que los pagos confirmados.';
    END IF;
END$$

DELIMITER ;


-- ============================================================
-- PASO 7: CONSULTAS DE USO Y REPORTES
-- ============================================================

-- 7.1 Buscar pacientes por documento o nombre.
SET @busqueda = '70000001';

SELECT
    id_paciente,
    tipo_documento,
    numero_documento,
    nombres,
    apellidos,
    telefono,
    correo
FROM pacientes
WHERE numero_documento = @busqueda
   OR CONCAT(nombres, ' ', apellidos) LIKE CONCAT('%', @busqueda, '%');


-- 7.2 Mostrar medicos y todas sus especialidades.
SELECT
    m.id_medico,
    CONCAT(m.nombres, ' ', m.apellidos) AS medico,
    GROUP_CONCAT(e.nombre ORDER BY e.nombre SEPARATOR ', ') AS especialidades
FROM medicos m
INNER JOIN medico_especialidad me
    ON m.id_medico = me.id_medico
INNER JOIN especialidades e
    ON me.id_especialidad = e.id_especialidad
GROUP BY m.id_medico, m.nombres, m.apellidos
ORDER BY medico;


-- 7.3 Consultar el historial de un paciente.
SELECT *
FROM vw_historial_pacientes
WHERE id_paciente = 1
ORDER BY fecha_hora DESC;


-- 7.4 Mostrar las consultas medicas registradas.
SELECT
    id_cita,
    paciente,
    medico,
    especialidad,
    fecha_consulta,
    diagnostico,
    tratamiento
FROM vw_historial_pacientes
WHERE fecha_consulta IS NOT NULL
ORDER BY fecha_consulta DESC;


-- 7.5 Identificar citas pendientes y canceladas.
SELECT
    id_cita,
    paciente,
    medico,
    especialidad,
    fecha_hora,
    estado_cita
FROM vw_citas_detalladas
WHERE estado_cita IN ('PROGRAMADA', 'CONFIRMADA', 'CANCELADA')
ORDER BY fecha_hora;


-- 7.6 Consultar pagos y saldos pendientes.
SELECT *
FROM vw_estado_pagos
ORDER BY id_cita;


-- 7.7 Consultar ingresos mensuales.
SELECT *
FROM vw_ingresos_mensuales
ORDER BY periodo;


-- 7.8 Obtener pacientes con mayor cantidad de citas.
SELECT
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellidos) AS paciente,
    COUNT(c.id_cita) AS total_citas,
    SUM(CASE WHEN c.estado_cita = 'ATENDIDA' THEN 1 ELSE 0 END) AS citas_atendidas
FROM pacientes p
LEFT JOIN citas c
    ON p.id_paciente = c.id_paciente
GROUP BY p.id_paciente, p.nombres, p.apellidos
ORDER BY total_citas DESC, paciente;


-- 7.9 Resumen de actividad por medico.
SELECT *
FROM vw_resumen_medicos
ORDER BY total_citas DESC, medico;


-- 7.10 Ingresos agrupados por metodo de pago.
SELECT
    metodo_pago,
    COUNT(*) AS cantidad_operaciones,
    SUM(monto) AS total_recaudado
FROM pagos
WHERE estado_pago = 'CONFIRMADO'
GROUP BY metodo_pago
ORDER BY total_recaudado DESC;


-- 7.11 Especialidades con mayor cantidad de citas.
SELECT
    e.id_especialidad,
    e.nombre AS especialidad,
    COUNT(c.id_cita) AS total_citas
FROM especialidades e
LEFT JOIN citas c
    ON e.id_especialidad = c.id_especialidad
GROUP BY e.id_especialidad, e.nombre
ORDER BY total_citas DESC, especialidad;


-- ============================================================
-- PRUEBAS FINALES DE INTEGRIDAD
-- Las consultas siguientes deben devolver cero filas o los
-- conteos esperados descritos en el README.
-- ============================================================

-- A. Conteo de registros por tabla.
SELECT 'pacientes' AS tabla, COUNT(*) AS registros FROM pacientes
UNION ALL
SELECT 'medicos', COUNT(*) FROM medicos
UNION ALL
SELECT 'especialidades', COUNT(*) FROM especialidades
UNION ALL
SELECT 'medico_especialidad', COUNT(*) FROM medico_especialidad
UNION ALL
SELECT 'citas', COUNT(*) FROM citas
UNION ALL
SELECT 'consultas', COUNT(*) FROM consultas
UNION ALL
SELECT 'pagos', COUNT(*) FROM pagos;


-- B. Citas cuyo paciente no existe: debe devolver cero filas.
SELECT c.id_cita
FROM citas c
LEFT JOIN pacientes p ON c.id_paciente = p.id_paciente
WHERE p.id_paciente IS NULL;


-- C. Citas con combinacion medico-especialidad inexistente:
-- debe devolver cero filas.
SELECT c.id_cita
FROM citas c
LEFT JOIN medico_especialidad me
    ON c.id_medico = me.id_medico
   AND c.id_especialidad = me.id_especialidad
WHERE me.id_medico IS NULL;


-- D. Consultas sin cita asociada: debe devolver cero filas.
SELECT co.id_consulta
FROM consultas co
LEFT JOIN citas c ON co.id_cita = c.id_cita
WHERE c.id_cita IS NULL;


-- E. Pagos que superan el costo de su cita: debe devolver cero filas.
SELECT
    c.id_cita,
    c.costo_total,
    SUM(CASE WHEN pg.estado_pago = 'CONFIRMADO' THEN pg.monto ELSE 0 END) AS total_pagado
FROM citas c
LEFT JOIN pagos pg ON c.id_cita = pg.id_cita
GROUP BY c.id_cita, c.costo_total
HAVING total_pagado > c.costo_total;


-- F. Citas superpuestas del mismo medico: debe devolver cero filas.
SELECT
    a.id_cita AS cita_1,
    b.id_cita AS cita_2,
    a.id_medico
FROM citas a
INNER JOIN citas b
    ON a.id_medico = b.id_medico
   AND a.id_cita < b.id_cita
   AND a.estado_cita NOT IN ('CANCELADA', 'NO_ASISTIO')
   AND b.estado_cita NOT IN ('CANCELADA', 'NO_ASISTIO')
   AND a.fecha_hora < DATE_ADD(b.fecha_hora, INTERVAL b.duracion_minutos MINUTE)
   AND DATE_ADD(a.fecha_hora, INTERVAL a.duracion_minutos MINUTE) > b.fecha_hora;


-- G. Consultas asociadas a citas que no figuran como ATENDIDA:
-- debe devolver cero filas con los datos de prueba actuales.
SELECT co.id_consulta, c.id_cita, c.estado_cita
FROM consultas co
INNER JOIN citas c ON co.id_cita = c.id_cita
WHERE c.estado_cita <> 'ATENDIDA';


-- ============================================================
-- PRUEBAS MANUALES OPCIONALES DE LOS TRIGGERS
-- Se dejan comentadas porque deben producir un error controlado.
-- Descomentar y ejecutar individualmente si se desea comprobar.
-- ============================================================

-- Prueba 1: intentar registrar un pago superior al saldo pendiente.
-- Debe ser rechazado por trg_pagos_validar_insert.
--
-- INSERT INTO pagos (id_cita, monto, metodo_pago, estado_pago)
-- VALUES (1, 999.00, 'EFECTIVO', 'CONFIRMADO');


-- Prueba 2: intentar programar dos citas superpuestas para el mismo medico.
-- Debe ser rechazado por trg_citas_validar_horario_insert.
--
-- INSERT INTO citas
-- (id_paciente, id_medico, id_especialidad, fecha_hora,
--  duracion_minutos, motivo, costo_total, estado_cita)
-- VALUES
-- (9, 1, 1, '2026-11-03 09:15:00', 30,
--  'Prueba de cruce de horario', 100.00, 'PROGRAMADA');


-- ============================================================
-- FIN DE LA FASE 2
-- ============================================================
