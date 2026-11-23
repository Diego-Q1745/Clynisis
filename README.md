# CLINISYS – Sistema web de gestión de clínica

Proyecto académico full-stack desarrollado con **PHP, MySQL, HTML, CSS y JavaScript**.

CLINISYS permite administrar pacientes, consultar médicos y especialidades, programar citas, registrar consultas y controlar pagos parciales en soles peruanos.

## Contenido del repositorio

```text
CLINISYS/
├── assets/
│   ├── css/style.css
│   └── js/app.js
├── config/
│   ├── .htaccess
│   └── database.example.php
├── database/
│   ├── 00_instalacion_completa.sql
│   ├── 01_esquema.sql
│   ├── 02_datos_prueba.sql
│   └── 03_vistas_triggers_reportes.sql
├── docs/
│   └── modelo_relacional.md
├── includes/
│   ├── bootstrap.php
│   ├── footer.php
│   └── header.php
├── appointments.php
├── consultations.php
├── doctors.php
├── index.php
├── patients.php
├── payments.php
├── .gitignore
├── .htaccess
└── README.md
```

## Módulos

- **Panel general:** indicadores de pacientes, médicos, citas e ingresos; agenda del día y pagos por método.
- **Pacientes:** búsqueda, registro, edición y cambio de estado.
- **Médicos:** consulta de médicos y sus especialidades.
- **Citas:** programación de citas y actualización de estados.
- **Consultas:** registro de consultas asociadas a citas atendidas.
- **Pagos:** registro de pagos parciales, total abonado y saldo pendiente.

## Requisitos

- PHP 8.1 o superior.
- MySQL 8.0.16 o superior.
- Extensión PHP `pdo_mysql`.
- Apache (XAMPP, WAMP o hosting compatible) o servidor PHP equivalente.

## Instalación de la base de datos

### Opción A: instalar todo de una vez

1. Abre MySQL Workbench.
2. Abre `database/00_instalacion_completa.sql`.
3. Ejecuta el script completo.
4. Comprueba que se hayan creado las siete tablas, los datos de prueba, las vistas y los triggers.

Este script crea la base de datos `CLINISYS_DB` si no existe. Los datos de prueba se insertan con identificadores fijos, por lo que **no debes ejecutar la instalación completa repetidamente sobre una base ya poblada**.

### Opción B: ejecutar por etapas

Ejecuta los archivos en este orden:

1. `database/01_esquema.sql`
2. `database/02_datos_prueba.sql`
3. `database/03_vistas_triggers_reportes.sql`

La tercera parte crea vistas, triggers, consultas de reportes y pruebas de integridad.

## Configurar la conexión PHP

1. Copia `config/database.example.php`.
2. Renombra la copia como `database.php`.
3. Completa host, base de datos, usuario y contraseña de MySQL.

Ejemplo local:

```php
return [
    'host' => 'localhost',
    'database' => 'CLINISYS_DB',
    'username' => 'root',
    'password' => '',
    'charset' => 'utf8mb4',
];
```

No publiques `config/database.php`. Está excluido mediante `.gitignore`.

## Ejecutar localmente con XAMPP

1. Copia la carpeta `CLINISYS` dentro de `C:/xampp/htdocs/`.
2. Inicia Apache y MySQL.
3. Ejecuta los scripts SQL.
4. Configura `config/database.php`.
5. Abre `http://localhost/CLINISYS/`.

## Subir a GitHub

1. Crea un repositorio llamado `CLINISYS`.
2. Sube el contenido de esta carpeta.
3. Verifica que `config/database.php` no aparezca entre los archivos.
4. Incluye este README para explicar instalación y tecnologías.

**GitHub Pages no ejecuta PHP.** El repositorio público sirve para mostrar y compartir el código fuente; para publicar la aplicación funcionando se necesita un hosting compatible con PHP y MySQL.

## Datos de prueba

Los registros son completamente ficticios y se incluyen únicamente para demostración:

| Tabla | Registros |
|---|---:|
| pacientes | 10 |
| medicos | 5 |
| especialidades | 6 |
| medico_especialidad | 8 |
| citas | 12 |
| consultas | 8 |
| pagos | 15 |
| **Total** | **64** |

## Tecnologías

- PHP 8.1+
- MySQL 8.0.16+
- PDO
- HTML5
- CSS3
- JavaScript
- MySQL Workbench

## Alcance y seguridad

Esta es una versión académica y demostrativa. No debe utilizarse para almacenar ni procesar información clínica real sin implementar autenticación, roles y permisos, auditoría, cifrado, copias de seguridad, HTTPS y medidas de protección de datos adecuadas.

El módulo de médicos es de consulta en esta versión. La creación de médicos y la asignación de especialidades se realiza directamente en la base de datos.

Los cambios de estado de pacientes y citas en esta versión inicial se efectúan mediante enlaces GET; deben convertirse a operaciones POST protegidas con token CSRF antes de un despliegue público de producción.
