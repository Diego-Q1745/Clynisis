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
