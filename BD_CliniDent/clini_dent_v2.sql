-- ============================================================
--  BD: OdontoGest — Clínica Dental
--  Versión: 2.0 (esquema corregido por docente)
--  Moneda: Lempira (L)
--  Impuesto ISV Honduras: 0% | 15% | 18%
-- ============================================================

CREATE DATABASE IF NOT EXISTS odontogest
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE odontogest;

-- ============================================================
-- BLOQUE 1 — SEGURIDAD Y USUARIOS
-- ============================================================

CREATE TABLE Roles (
    id_rol      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(60)  NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

CREATE TABLE Permisos (
    id_permiso  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

CREATE TABLE Usuarios (
    id_usuario  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_rol      INT UNSIGNED NOT NULL,
    usuario     VARCHAR(80)  NOT NULL UNIQUE,
    contrasena  VARCHAR(255) NOT NULL,          -- hash bcrypt
    estado      TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_usr_rol FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
);

-- Tabla de imagen de perfil de usuario (KV = key:carpeta / value:archivo)
CREATE TABLE KV_IMG (
    id_kv_img   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `key`       VARCHAR(200) NOT NULL,          -- nombre de carpeta
    `value`     VARCHAR(200) NOT NULL           -- nombre de archivo
);

CREATE TABLE Imagenes (
    id_imagen   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    url         VARCHAR(500) NOT NULL,
    id_kv_img   INT UNSIGNED NULL,
    CONSTRAINT fk_img_kv FOREIGN KEY (id_kv_img) REFERENCES KV_IMG(id_kv_img)
);

-- Agrega FK de imagen al usuario (después de crear Imagenes)
ALTER TABLE Usuarios
    ADD COLUMN id_img_user INT UNSIGNED NULL,
    ADD CONSTRAINT fk_usr_img FOREIGN KEY (id_img_user) REFERENCES Imagenes(id_imagen);

CREATE TABLE Permisos_Roles (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_rol      INT UNSIGNED NOT NULL,
    id_permiso  INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_rol_permiso (id_rol, id_permiso),
    CONSTRAINT fk_pr_rol     FOREIGN KEY (id_rol)     REFERENCES Roles(id_rol),
    CONSTRAINT fk_pr_permiso FOREIGN KEY (id_permiso) REFERENCES Permisos(id_permiso)
);

-- ============================================================
-- BLOQUE 2 — ESTRUCTURA CLÍNICA (ODONTÓLOGOS Y EMPLEADOS)
-- ============================================================

CREATE TABLE Cargo (
    id_cargo    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    estado      TINYINT(1)   NOT NULL DEFAULT 1
);

CREATE TABLE Especialidades (
    id_especialidad INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    descripcion     VARCHAR(200)
);

-- Odontólogos: entidad clínica separada (más campos, más privilegios)
CREATE TABLE Odontologos (
    id_odontologo   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT UNSIGNED NOT NULL UNIQUE, -- 1:1 con Usuarios
    id_cargo        INT UNSIGNED NULL,
    id_especialidad INT UNSIGNED NULL,
    nombre          VARCHAR(100) NOT NULL,
    codigo_legi     VARCHAR(50)  NULL,            -- código colegio médico
    fecha_nac       DATE         NULL,
    estado          TINYINT(1)   NOT NULL DEFAULT 1,
    descripcion     TEXT,
    CONSTRAINT fk_odo_usuario      FOREIGN KEY (id_usuario)      REFERENCES Usuarios(id_usuario),
    CONSTRAINT fk_odo_cargo        FOREIGN KEY (id_cargo)        REFERENCES Cargo(id_cargo),
    CONSTRAINT fk_odo_especialidad FOREIGN KEY (id_especialidad) REFERENCES Especialidades(id_especialidad)
);

-- Empleados: recepcionistas, administrativos, etc.
CREATE TABLE Empleados (
    id_empleado INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario  INT UNSIGNED NOT NULL UNIQUE,
    id_cargo    INT UNSIGNED NULL,
    nombre      VARCHAR(100) NOT NULL,
    telefono    VARCHAR(20),
    fecha_nac   DATE,
    estado      TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_emp_usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    CONSTRAINT fk_emp_cargo   FOREIGN KEY (id_cargo)   REFERENCES Cargo(id_cargo)
);

CREATE TABLE HorarioLaboral (
    id_horario_lab  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT UNSIGNED NOT NULL,
    dia             ENUM('Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo') NOT NULL,
    hora_entrada    TIME         NOT NULL,
    hora_salida     TIME         NOT NULL,
    estado          TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_hl_usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

-- ============================================================
-- BLOQUE 3 — CATÁLOGOS CLÍNICOS
-- ============================================================

CREATE TABLE Sangres (
    id_sangre   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(10) NOT NULL UNIQUE    -- A+, B-, O+, etc.
);

CREATE TABLE Alergias (
    id_alergia  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(150) NOT NULL
);

CREATE TABLE Enfermedades (
    id_enfermedad INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion   VARCHAR(150) NOT NULL
);

CREATE TABLE Medicamentos (
    id_medicamento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion    VARCHAR(150) NOT NULL
);

-- Tratamientos: procedimientos clínicos asignados a citas
CREATE TABLE Tratamientos (
    id_tratamiento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion    VARCHAR(200) NOT NULL
);

-- ============================================================
-- BLOQUE 4 — PACIENTES Y EXPEDIENTES
-- ============================================================

CREATE TABLE Pacientes (
    id_paciente     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    dni             VARCHAR(20)  NULL UNIQUE,
    rtn             VARCHAR(20)  NULL,
    fecha_nac       DATE,
    telefono        VARCHAR(20),
    id_img_paciente INT UNSIGNED NULL,
    CONSTRAINT fk_pac_img FOREIGN KEY (id_img_paciente) REFERENCES Imagenes(id_imagen)
);

CREATE TABLE Expedientes (
    id_expediente           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_paciente             INT UNSIGNED NOT NULL UNIQUE,
    id_sangre               INT UNSIGNED NULL,
    id_alergia              INT UNSIGNED NULL,
    id_enfermedad           INT UNSIGNED NULL,
    id_medicamento_actual   INT UNSIGNED NULL,
    antecedentes_familiares TEXT,
    observaciones           TEXT,
    id_img_expediente       INT UNSIGNED NULL,
    fecha_creacion          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion      DATETIME     NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_exp_paciente    FOREIGN KEY (id_paciente)           REFERENCES Pacientes(id_paciente),
    CONSTRAINT fk_exp_sangre      FOREIGN KEY (id_sangre)             REFERENCES Sangres(id_sangre),
    CONSTRAINT fk_exp_alergia     FOREIGN KEY (id_alergia)            REFERENCES Alergias(id_alergia),
    CONSTRAINT fk_exp_enfermedad  FOREIGN KEY (id_enfermedad)         REFERENCES Enfermedades(id_enfermedad),
    CONSTRAINT fk_exp_medicamento FOREIGN KEY (id_medicamento_actual)  REFERENCES Medicamentos(id_medicamento),
    CONSTRAINT fk_exp_img         FOREIGN KEY (id_img_expediente)     REFERENCES Imagenes(id_imagen)
);

-- Odontograma: estado de cada pieza dental por expediente
CREATE TABLE Odontograma (
    id_odontograma  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_expediente   INT UNSIGNED NOT NULL,
    id_odontologo   INT UNSIGNED NOT NULL,
    pieza_dental    TINYINT UNSIGNED NOT NULL,   -- número FDI: 11-48
    condicion       VARCHAR(50)  NOT NULL,       -- sano, caries, corona, etc.
    color_codigo    VARCHAR(10)  NULL,           -- hex del color en UI
    descripcion     VARCHAR(300) NULL,
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificado DATETIME    NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_odo_exp    FOREIGN KEY (id_expediente) REFERENCES Expedientes(id_expediente),
    CONSTRAINT fk_odo_doctor FOREIGN KEY (id_odontologo) REFERENCES Odontologos(id_odontologo)
);

-- Historial de tratamientos por paciente
CREATE TABLE Tratamientos_Historial (
    id_historial    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_paciente     INT UNSIGNED NOT NULL,
    id_tratamiento  INT UNSIGNED NOT NULL,
    descripcion     VARCHAR(300) NULL,
    CONSTRAINT fk_th_paciente    FOREIGN KEY (id_paciente)    REFERENCES Pacientes(id_paciente),
    CONSTRAINT fk_th_tratamiento FOREIGN KEY (id_tratamiento) REFERENCES Tratamientos(id_tratamiento)
);

-- ============================================================
-- BLOQUE 5 — AGENDA Y CITAS
-- ============================================================

-- Horarios disponibles para citas
CREATE TABLE Horarios (
    id_horario  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dia         DATE         NOT NULL,
    hora        TIME         NOT NULL,
    fecha       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_slot (dia, hora)              -- 1 cita por hora por día
);

-- Servicios: catálogo de lo que se cobra (vinculado a Factura)
CREATE TABLE Servicios (
    id_servicio INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(150) NOT NULL,
    descripcion TEXT,
    costo       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    impuesto    DECIMAL(4,2)  NOT NULL DEFAULT 0.00  -- 0.00 | 0.15 | 0.18
    -- CONSTRAINT chk_isv CHECK (impuesto IN (0.00, 0.15, 0.18))
);

CREATE TABLE Citas (
    id_cita         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_odontologo   INT UNSIGNED NOT NULL,
    id_paciente     INT UNSIGNED NOT NULL,
    id_horario      INT UNSIGNED NOT NULL UNIQUE, -- 1 cita por slot
    id_servicio     INT UNSIGNED NULL,            -- servicio tentativo al agendar
    id_tratamiento  INT UNSIGNED NULL,            -- tratamiento clínico asignado
    id_img_cita     INT UNSIGNED NULL,
    estado          ENUM('pendiente','confirmada','atendida','cancelada') NOT NULL DEFAULT 'pendiente',
    CONSTRAINT fk_cita_odo        FOREIGN KEY (id_odontologo)  REFERENCES Odontologos(id_odontologo),
    CONSTRAINT fk_cita_pac        FOREIGN KEY (id_paciente)    REFERENCES Pacientes(id_paciente),
    CONSTRAINT fk_cita_horario    FOREIGN KEY (id_horario)     REFERENCES Horarios(id_horario),
    CONSTRAINT fk_cita_servicio   FOREIGN KEY (id_servicio)    REFERENCES Servicios(id_servicio),
    CONSTRAINT fk_cita_trat       FOREIGN KEY (id_tratamiento) REFERENCES Tratamientos(id_tratamiento),
    CONSTRAINT fk_cita_img        FOREIGN KEY (id_img_cita)    REFERENCES Imagenes(id_imagen)
);

-- ============================================================
-- BLOQUE 6 — INVENTARIO
-- ============================================================

CREATE TABLE Proveedores (
    id_proveedor INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    proveedor    VARCHAR(150) NOT NULL,
    telefono     VARCHAR(20),
    correo       VARCHAR(150),
    ubicacion    VARCHAR(300)
);

-- KV para rutas de archivos de productos (key=carpeta, value=archivo)
CREATE TABLE KV_Producto (
    id_kv_producto INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `key`          VARCHAR(200) NOT NULL,
    `value`        VARCHAR(200) NOT NULL
);

CREATE TABLE Producto (
    id_producto    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_proveedor   INT UNSIGNED NULL,
    id_kv_producto INT UNSIGNED NULL,
    nombre         VARCHAR(150) NOT NULL,
    stock          INT UNSIGNED NOT NULL DEFAULT 0,
    impuesto       DECIMAL(4,2) NOT NULL DEFAULT 0.00, -- 0.00 | 0.15 | 0.18
    estado         TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_prod_proveedor  FOREIGN KEY (id_proveedor)   REFERENCES Proveedores(id_proveedor),
    CONSTRAINT fk_prod_kv         FOREIGN KEY (id_kv_producto) REFERENCES KV_Producto(id_kv_producto)
);

CREATE TABLE Reportes_Inventario (
    id_reporte_inv      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_producto         INT UNSIGNED NOT NULL,
    accion              VARCHAR(100) NOT NULL,   -- entrada, salida, ajuste
    fecha_modificacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_modificador INT UNSIGNED NOT NULL,
    CONSTRAINT fk_ri_producto FOREIGN KEY (id_producto)         REFERENCES Producto(id_producto),
    CONSTRAINT fk_ri_usuario  FOREIGN KEY (usuario_modificador) REFERENCES Usuarios(id_usuario)
);

-- ============================================================
-- BLOQUE 7 — FACTURACIÓN
-- ============================================================

CREATE TABLE Sucursal (
    id_sucursal INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(150) NOT NULL,
    ubicacion   VARCHAR(300),
    contacto    VARCHAR(100)
);

CREATE TABLE Factura (
    id_factura          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_paciente         INT UNSIGNED NOT NULL,
    id_cita             INT UNSIGNED NOT NULL UNIQUE,
    id_usuario          INT UNSIGNED NOT NULL,  -- quien emite la factura
    rtn                 VARCHAR(20)  NULL,       -- RTN del cliente (opcional)
    impuesto            DECIMAL(4,2) NOT NULL DEFAULT 0.00, -- 0.00 | 0.15 | 0.18
    subtotal            DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total               DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    metodo_pago         ENUM('efectivo','tarjeta','transferencia') NOT NULL DEFAULT 'efectivo',
    estado              ENUM('emitida','pagada','anulada') NOT NULL DEFAULT 'emitida',
    fecha_emision       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_creada        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion  DATETIME     NULL ON UPDATE CURRENT_TIMESTAMP,
    responsable_anulado INT UNSIGNED NULL,       -- id_usuario que anuló
    CONSTRAINT fk_fac_paciente  FOREIGN KEY (id_paciente)          REFERENCES Pacientes(id_paciente),
    CONSTRAINT fk_fac_cita      FOREIGN KEY (id_cita)              REFERENCES Citas(id_cita),
    CONSTRAINT fk_fac_usuario   FOREIGN KEY (id_usuario)           REFERENCES Usuarios(id_usuario),
    CONSTRAINT fk_fac_anulador  FOREIGN KEY (responsable_anulado)  REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Detalle_Factura (
    id_detalle      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_factura      INT UNSIGNED NOT NULL,
    id_servicio     INT UNSIGNED NOT NULL,
    descripcion     VARCHAR(300) NULL,
    cantidad        TINYINT UNSIGNED NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2)    NOT NULL,
    subtotal        DECIMAL(10,2)    NOT NULL,
    impuesto        DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_df_factura  FOREIGN KEY (id_factura)  REFERENCES Factura(id_factura),
    CONSTRAINT fk_df_servicio FOREIGN KEY (id_servicio) REFERENCES Servicios(id_servicio)
);

-- Historial de productos consumidos por factura
CREATE TABLE Historial (
    id_historial INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_factura   INT UNSIGNED NOT NULL,
    id_usuario   INT UNSIGNED NOT NULL,
    id_producto  INT UNSIGNED NOT NULL,
    CONSTRAINT fk_his_factura  FOREIGN KEY (id_factura)  REFERENCES Factura(id_factura),
    CONSTRAINT fk_his_usuario  FOREIGN KEY (id_usuario)  REFERENCES Usuarios(id_usuario),
    CONSTRAINT fk_his_producto FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

-- ============================================================
-- BLOQUE 8 — SISTEMA (AUDITORÍA, REPORTES, NOTIFICACIONES)
-- ============================================================

CREATE TABLE Auditoria (
    id_auditoria INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario   INT UNSIGNED NOT NULL,
    modulo       VARCHAR(80)  NOT NULL,
    accion       VARCHAR(80)  NOT NULL,
    descripcion  TEXT,
    fecha        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip           VARCHAR(45)  NULL,              -- IPv4 o IPv6
    CONSTRAINT fk_aud_usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

-- KV genérico para reportes (key=parámetro, value=dato)
CREATE TABLE Reportes (
    id_reporte  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    kv_reporte  VARCHAR(100) NOT NULL,           -- nombre/tipo del reporte
    `key`       VARCHAR(200) NOT NULL,
    `value`     TEXT         NOT NULL,
    fecha       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Notificaciones (
    id_notificacion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT UNSIGNED NOT NULL,
    mensaje         TEXT         NOT NULL,
    fecha           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          ENUM('no_leida','leida') NOT NULL DEFAULT 'no_leida',
    CONSTRAINT fk_noti_usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Configuracion (
    id_config   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO Roles (nombre, descripcion) VALUES
    ('Admin',         'Acceso total al sistema'),
    ('Odontólogo',    'Acceso clínico completo'),
    ('Recepcionista', 'Gestión de citas y pacientes');

INSERT INTO Sangres (descripcion) VALUES
    ('A+'),('A-'),('B+'),('B-'),('AB+'),('AB-'),('O+'),('O-');

INSERT INTO Cargo (nombre, descripcion) VALUES
    ('Odontólogo General',    'Atención dental de primera línea'),
    ('Ortodoncista',          'Especialista en ortodoncia'),
    ('Endodoncista',          'Especialista en endodoncia'),
    ('Recepcionista',         'Atención al cliente y agenda'),
    ('Administrador',         'Gestión administrativa');
