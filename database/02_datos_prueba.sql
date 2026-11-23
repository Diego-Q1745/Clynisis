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
