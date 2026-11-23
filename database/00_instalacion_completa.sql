-- CLINISYS - INSTALACION COMPLETA
-- Ejecutar en orden: esquema, datos de prueba, vistas/triggers/reportes.
-- Requiere MySQL 8.0.16 o superior.

-- ============================================================
-- CLINISYS - ESQUEMA COMPLETO DE BASE DE DATOS
-- Requiere MySQL 8.0.16 o superior
-- ============================================================

CREATE DATABASE IF NOT EXISTS CLINISYS_DB
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE CLINISYS_DB;

-- TABLA 1: PACIENTES
CREATE TABLE IF NOT EXISTS pacientes (
    id_paciente INT UNSIGNED AUTO_INCREMENT,
    tipo_documento VARCHAR(15) NOT NULL,
    numero_documento VARCHAR(20) NOT NULL,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    sexo ENUM('F', 'M', 'OTRO', 'NO_ESPECIFICA') NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(120),
    direccion VARCHAR(180),
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    PRIMARY KEY (id_paciente),
    CONSTRAINT uq_pacientes_documento UNIQUE (tipo_documento, numero_documento),
    CONSTRAINT chk_pacientes_documento
        CHECK (tipo_documento IN ('DNI', 'CE', 'PASAPORTE'))
) ENGINE=InnoDB;

-- TABLA 2: MEDICOS
CREATE TABLE IF NOT EXISTS medicos (
    id_medico INT UNSIGNED AUTO_INCREMENT,
    tipo_documento VARCHAR(15) NOT NULL,
    numero_documento VARCHAR(20) NOT NULL,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    numero_colegiatura VARCHAR(20) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(120),
    fecha_contratacion DATE NOT NULL,
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    PRIMARY KEY (id_medico),
    CONSTRAINT uq_medicos_documento UNIQUE (tipo_documento, numero_documento),
    CONSTRAINT uq_medicos_colegiatura UNIQUE (numero_colegiatura),
    CONSTRAINT chk_medicos_documento
        CHECK (tipo_documento IN ('DNI', 'CE', 'PASAPORTE'))
) ENGINE=InnoDB;

-- TABLA 3: ESPECIALIDADES
CREATE TABLE IF NOT EXISTS especialidades (
    id_especialidad INT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(255),
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    PRIMARY KEY (id_especialidad),
    CONSTRAINT uq_especialidades_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

-- TABLA 4: MEDICO_ESPECIALIDAD
-- Resuelve la relación muchos a muchos entre médicos y especialidades.
CREATE TABLE IF NOT EXISTS medico_especialidad (
    id_medico INT UNSIGNED NOT NULL,
    id_especialidad INT UNSIGNED NOT NULL,
    fecha_asignacion DATE NOT NULL,
    PRIMARY KEY (id_medico, id_especialidad),
    CONSTRAINT fk_me_medico
        FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_me_especialidad
        FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- TABLA 5: CITAS
CREATE TABLE IF NOT EXISTS citas (
    id_cita INT UNSIGNED AUTO_INCREMENT,
    id_paciente INT UNSIGNED NOT NULL,
    id_medico INT UNSIGNED NOT NULL,
    id_especialidad INT UNSIGNED NOT NULL,
    fecha_hora DATETIME NOT NULL,
    duracion_minutos SMALLINT UNSIGNED NOT NULL DEFAULT 30,
    motivo VARCHAR(255) NOT NULL,
    costo_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    estado_cita ENUM(
        'PROGRAMADA', 'CONFIRMADA', 'ATENDIDA', 'CANCELADA', 'NO_ASISTIO'
    ) NOT NULL DEFAULT 'PROGRAMADA',
    observaciones VARCHAR(255),
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_cita),
    INDEX idx_citas_paciente (id_paciente),
    INDEX idx_citas_medico_fecha (id_medico, fecha_hora),
    CONSTRAINT fk_citas_paciente
        FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_citas_medico_especialidad
        FOREIGN KEY (id_medico, id_especialidad)
        REFERENCES medico_especialidad(id_medico, id_especialidad)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_citas_duracion CHECK (duracion_minutos > 0),
    CONSTRAINT chk_citas_costo CHECK (costo_total >= 0)
) ENGINE=InnoDB;

-- TABLA 6: CONSULTAS
CREATE TABLE IF NOT EXISTS consultas (
    id_consulta INT UNSIGNED AUTO_INCREMENT,
    id_cita INT UNSIGNED NOT NULL,
    fecha_consulta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnostico TEXT NOT NULL,
    tratamiento TEXT,
    recomendaciones TEXT,
    observaciones TEXT,
    PRIMARY KEY (id_consulta),
    CONSTRAINT uq_consultas_cita UNIQUE (id_cita),
    CONSTRAINT fk_consultas_cita
        FOREIGN KEY (id_cita) REFERENCES citas(id_cita)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- TABLA 7: PAGOS
CREATE TABLE IF NOT EXISTS pagos (
    id_pago INT UNSIGNED AUTO_INCREMENT,
    id_cita INT UNSIGNED NOT NULL,
    fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM(
        'EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'YAPE', 'PLIN', 'OTRO'
    ) NOT NULL,
    referencia_pago VARCHAR(80),
    estado_pago ENUM('CONFIRMADO', 'ANULADO') NOT NULL DEFAULT 'CONFIRMADO',
    PRIMARY KEY (id_pago),
    INDEX idx_pagos_cita (id_cita),
    CONSTRAINT fk_pagos_cita
        FOREIGN KEY (id_cita) REFERENCES citas(id_cita)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_pagos_monto CHECK (monto > 0)
) ENGINE=InnoDB;

-- Verificar las tablas creadas.
SHOW TABLES;


-- ============================================================
-- CLINISYS - DATOS FICTICIOS DE PRUEBA
-- Ejecutar una sola vez después de 01_esquema.sql.
-- Contiene 64 registros distribuidos en 7 tablas.
-- ============================================================

USE CLINISYS_DB;
START TRANSACTION;

-- 1. PACIENTES (10)
INSERT INTO pacientes
(id_paciente, tipo_documento, numero_documento, nombres, apellidos,
 fecha_nacimiento, sexo, telefono, correo, direccion, fecha_registro, estado)
VALUES
(1,'DNI','70000001','Lucia','Mendoza Rojas','1998-04-12','F','987000001','lucia.mendoza@example.com','Av. Los Olivos 120','2026-10-01 08:00:00','ACTIVO'),
(2,'DNI','70000002','Mateo','Quispe Flores','1995-08-20','M','987000002','mateo.quispe@example.com','Jr. Primavera 250','2026-10-02 09:00:00','ACTIVO'),
(3,'DNI','70000003','Camila','Torres Vega','2010-02-15','F','987000003','camila.torres@example.com','Av. Central 350','2026-10-03 10:00:00','ACTIVO'),
(4,'DNI','70000004','Diego','Salazar Ruiz','2005-11-05','M','987000004','diego.salazar@example.com','Jr. Las Flores 180','2026-10-04 11:00:00','ACTIVO'),
(5,'DNI','70000005','Valeria','Rojas Medina','1992-06-18','F','987000005','valeria.rojas@example.com','Av. Progreso 420','2026-10-05 08:30:00','ACTIVO'),
(6,'DNI','70000006','Andres','Castillo Leon','1988-09-10','M','987000006','andres.castillo@example.com','Jr. Union 510','2026-10-06 09:30:00','ACTIVO'),
(7,'DNI','70000007','Sofia','Herrera Cruz','1999-12-22','F','987000007','sofia.herrera@example.com','Av. Libertad 600','2026-10-07 10:30:00','ACTIVO'),
(8,'DNI','70000008','Gabriel','Mendoza Silva','1985-03-14','M','987000008','gabriel.mendoza@example.com','Jr. San Martin 700','2026-10-08 11:30:00','ACTIVO'),
(9,'DNI','70000009','Emma','Vargas Soto','2001-07-09','F','987000009','emma.vargas@example.com','Av. Los Pinos 800','2026-10-09 08:45:00','ACTIVO'),
(10,'DNI','70000010','Nicolas','Flores Ramos','1996-01-25','M','987000010','nicolas.flores@example.com','Jr. Los Jazmines 900','2026-10-10 09:45:00','ACTIVO');

-- 2. MEDICOS (5)
INSERT INTO medicos
(id_medico, tipo_documento, numero_documento, nombres, apellidos,
 numero_colegiatura, telefono, correo, fecha_contratacion, estado)
VALUES
(1,'DNI','80000001','Carlos','Vargas Salazar','CMP-DEMO-001','986000001','carlos.vargas@example.com','2020-03-01','ACTIVO'),
(2,'DNI','80000002','Ana','Torres Medina','CMP-DEMO-002','986000002','ana.torres@example.com','2021-05-15','ACTIVO'),
(3,'DNI','80000003','Miguel','Rojas Paredes','CMP-DEMO-003','986000003','miguel.rojas@example.com','2019-08-10','ACTIVO'),
(4,'DNI','80000004','Elena','Castillo Ruiz','CMP-DEMO-004','986000004','elena.castillo@example.com','2022-01-20','ACTIVO'),
(5,'DNI','80000005','Javier','Mendoza Flores','CMP-DEMO-005','986000005','javier.mendoza@example.com','2023-04-12','ACTIVO');

-- 3. ESPECIALIDADES (6)
INSERT INTO especialidades (id_especialidad,nombre,descripcion,estado) VALUES
(1,'Cardiologia','Especialidad del sistema cardiovascular.','ACTIVO'),
(2,'Medicina Interna','Atencion integral de enfermedades del adulto.','ACTIVO'),
(3,'Pediatria','Atencion medica de ninos y adolescentes.','ACTIVO'),
(4,'Dermatologia','Atencion de enfermedades de la piel.','ACTIVO'),
(5,'Ginecologia','Atencion de la salud del sistema reproductor femenino.','ACTIVO'),
(6,'Neurologia','Atencion de enfermedades del sistema nervioso.','ACTIVO');

-- 4. MEDICO_ESPECIALIDAD (8)
INSERT INTO medico_especialidad (id_medico,id_especialidad,fecha_asignacion) VALUES
(1,1,'2020-03-01'),
(1,2,'2020-06-15'),
(2,3,'2021-05-15'),
(2,4,'2021-08-20'),
(3,4,'2019-08-10'),
(3,6,'2020-02-10'),
(4,5,'2022-01-20'),
(5,6,'2023-04-12');

-- 5. CITAS (12)
INSERT INTO citas
(id_cita,id_paciente,id_medico,id_especialidad,fecha_hora,duracion_minutos,
 motivo,costo_total,estado_cita,observaciones)
VALUES
(1,1,1,1,'2026-11-03 09:00:00',30,'Control cardiovascular',150.00,'ATENDIDA','Atencion realizada.'),
(2,2,1,2,'2026-11-03 10:00:00',30,'Evaluacion general',120.00,'ATENDIDA','Atencion realizada.'),
(3,3,2,3,'2026-11-04 09:00:00',30,'Control pediatrico',100.00,'ATENDIDA','Atencion realizada.'),
(4,4,2,4,'2026-11-04 10:00:00',30,'Evaluacion dermatologica',130.00,'ATENDIDA','Atencion realizada.'),
(5,5,3,6,'2026-11-05 09:00:00',30,'Evaluacion neurologica',110.00,'ATENDIDA','Atencion realizada.'),
(6,6,4,5,'2026-11-06 09:00:00',30,'Control ginecologico',160.00,'ATENDIDA','Atencion realizada.'),
(7,7,4,5,'2026-11-06 10:00:00',30,'Consulta ginecologica',140.00,'ATENDIDA','Atencion realizada.'),
(8,8,5,6,'2026-11-07 09:00:00',30,'Evaluacion neurologica',180.00,'ATENDIDA','Atencion realizada.'),
(9,9,5,6,'2026-11-24 10:00:00',30,'Control neurologico',180.00,'CONFIRMADA','Cita confirmada.'),
(10,10,3,4,'2026-11-25 09:00:00',30,'Control dermatologico',110.00,'PROGRAMADA','Pendiente de atencion.'),
(11,2,4,5,'2026-11-20 11:00:00',30,'Consulta ginecologica',160.00,'CANCELADA','Cita cancelada.'),
(12,1,1,1,'2026-11-19 11:00:00',30,'Control cardiovascular',150.00,'NO_ASISTIO','Paciente no asistio.');

-- 6. CONSULTAS (8)
INSERT INTO consultas
(id_consulta,id_cita,fecha_consulta,diagnostico,tratamiento,recomendaciones,observaciones)
VALUES
(1,1,'2026-11-03 09:30:00','Registro de evaluacion cardiovascular de prueba.','Seguimiento segun indicacion medica.','Acudir al siguiente control programado.','Registro ficticio para demostracion.'),
(2,2,'2026-11-03 10:30:00','Evaluacion general de prueba.','Indicaciones generales de seguimiento.','Mantener controles periodicos.','Registro ficticio para demostracion.'),
(3,3,'2026-11-04 09:30:00','Evaluacion pediatrica de prueba.','Seguimiento pediatrico.','Asistir al control correspondiente.','Registro ficticio para demostracion.'),
(4,4,'2026-11-04 10:30:00','Evaluacion dermatologica de prueba.','Tratamiento segun evaluacion profesional.','Realizar seguimiento de la atencion.','Registro ficticio para demostracion.'),
(5,5,'2026-11-05 09:30:00','Evaluacion neurologica de prueba.','Seguimiento segun indicacion medica.','Programar control si corresponde.','Registro ficticio para demostracion.'),
(6,6,'2026-11-06 09:30:00','Evaluacion ginecologica de prueba.','Seguimiento ginecologico.','Mantener controles preventivos.','Registro ficticio para demostracion.'),
(7,7,'2026-11-06 10:30:00','Consulta ginecologica de prueba.','Indicaciones de seguimiento.','Asistir a la proxima evaluacion.','Registro ficticio para demostracion.'),
(8,8,'2026-11-07 09:30:00','Evaluacion neurologica de prueba.','Seguimiento profesional.','Continuar controles segun indicacion.','Registro ficticio para demostracion.');

-- 7. PAGOS (15)
INSERT INTO pagos
(id_pago,id_cita,fecha_pago,monto,metodo_pago,referencia_pago,estado_pago)
VALUES
(1,1,'2026-11-03 09:35:00',100.00,'EFECTIVO','PAY-DEMO-001','CONFIRMADO'),
(2,1,'2026-11-03 09:40:00',50.00,'YAPE','PAY-DEMO-002','CONFIRMADO'),
(3,2,'2026-11-03 10:35:00',70.00,'TARJETA','PAY-DEMO-003','CONFIRMADO'),
(4,2,'2026-11-03 10:40:00',50.00,'EFECTIVO','PAY-DEMO-004','CONFIRMADO'),
(5,3,'2026-11-04 09:35:00',50.00,'YAPE','PAY-DEMO-005','CONFIRMADO'),
(6,3,'2026-11-04 09:40:00',50.00,'EFECTIVO','PAY-DEMO-006','CONFIRMADO'),
(7,4,'2026-11-04 10:35:00',80.00,'TARJETA','PAY-DEMO-007','CONFIRMADO'),
(8,4,'2026-11-04 10:40:00',50.00,'YAPE','PAY-DEMO-008','CONFIRMADO'),
(9,5,'2026-11-05 09:35:00',110.00,'TRANSFERENCIA','PAY-DEMO-009','CONFIRMADO'),
(10,6,'2026-11-06 09:35:00',100.00,'YAPE','PAY-DEMO-010','CONFIRMADO'),
(11,6,'2026-11-06 09:40:00',60.00,'EFECTIVO','PAY-DEMO-011','CONFIRMADO'),
(12,7,'2026-11-06 10:35:00',140.00,'TARJETA','PAY-DEMO-012','CONFIRMADO'),
(13,8,'2026-11-07 09:35:00',100.00,'TRANSFERENCIA','PAY-DEMO-013','CONFIRMADO'),
(14,8,'2026-11-07 09:40:00',50.00,'YAPE','PAY-DEMO-014','CONFIRMADO'),
(15,8,'2026-11-07 09:45:00',30.00,'EFECTIVO','PAY-DEMO-015','CONFIRMADO');

COMMIT;

-- Conteo esperado: 10 pacientes, 5 medicos, 6 especialidades,
-- 8 relaciones medico-especialidad, 12 citas, 8 consultas, 15 pagos.
SELECT 'pacientes' AS tabla, COUNT(*) AS registros FROM pacientes
UNION ALL SELECT 'medicos', COUNT(*) FROM medicos
UNION ALL SELECT 'especialidades', COUNT(*) FROM especialidades
UNION ALL SELECT 'medico_especialidad', COUNT(*) FROM medico_especialidad
UNION ALL SELECT 'citas', COUNT(*) FROM citas
UNION ALL SELECT 'consultas', COUNT(*) FROM consultas
UNION ALL SELECT 'pagos', COUNT(*) FROM pagos;


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
