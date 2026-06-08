-- ============================================================
--  BD: CliniDent — Clínica Dental
--  Versión: 1.1 (correcciones aplicadas)
-- ============================================================

CREATE DATABASE IF NOT EXISTS clini_dent
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE clini_dent;

-- ------------------------------------------------------------
-- ROLES Y PERMISOS
-- ------------------------------------------------------------

CREATE TABLE Roles (
    id_rol      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_rol  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Permisos (
    id_permiso  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(150) NOT NULL
);

CREATE TABLE Rol_Permiso (
    id_rol_permiso  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_rol          INT UNSIGNED NOT NULL,
    id_permiso      INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_rol_permiso (id_rol, id_permiso),
    CONSTRAINT fk_rp_rol     FOREIGN KEY (id_rol)     REFERENCES Roles(id_rol),
    CONSTRAINT fk_rp_permiso FOREIGN KEY (id_permiso) REFERENCES Permisos(id_permiso)
);

-- ------------------------------------------------------------
-- USUARIOS  (Admin | Odontólogo | Recepcionista)
-- ------------------------------------------------------------

CREATE TABLE Usuarios (
    id_usuario      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_rol          INT UNSIGNED NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    correo          VARCHAR(150) NOT NULL UNIQUE,
    contrasena      VARCHAR(255) NOT NULL,          -- hash bcrypt
    telefono        VARCHAR(20),
    url_foto        VARCHAR(500),
    fecha_creado    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado          TINYINT(1)   NOT NULL DEFAULT 1, -- 1=activo 0=inactivo
    descripcion     TEXT,
    CONSTRAINT fk_usr_rol FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
);

-- ------------------------------------------------------------
-- CLIENTES / PACIENTES
-- ------------------------------------------------------------

CREATE TABLE Clientes (
    id_cliente      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    telefono        VARCHAR(20),
    correo          VARCHAR(150),
    fecha_nacimiento DATE,
    direccion       VARCHAR(300),
    url_foto        VARCHAR(500)
);

-- ------------------------------------------------------------
-- EXPEDIENTES CLÍNICOS
-- ------------------------------------------------------------

CREATE TABLE Expedientes (
    id_expediente       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_cliente          INT UNSIGNED NOT NULL UNIQUE,   -- 1 expediente por cliente
    fecha_creacion      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observaciones       TEXT,
    alergias            TEXT,
    antecedentes_medicos TEXT,
    CONSTRAINT fk_exp_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

CREATE TABLE Img_Expedientes (
    id_imagen       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_expediente   INT UNSIGNED NOT NULL,
    url_imagen      VARCHAR(500) NOT NULL,
    descripcion     VARCHAR(300),
    CONSTRAINT fk_img_exp FOREIGN KEY (id_expediente) REFERENCES Expedientes(id_expediente)
);

-- ------------------------------------------------------------
-- HORARIOS Y CITAS
-- Regla: solo UNA cita por slot (fecha + hora_inicio únicos)
-- ------------------------------------------------------------

CREATE TABLE Horarios (
    id_horario  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario  INT UNSIGNED NOT NULL,               -- odontólogo asignado
    fecha       DATE         NOT NULL,
    hora_inicio TIME         NOT NULL,
    hora_fin    TIME         NOT NULL,
    estado      ENUM('disponible','ocupado','cancelado') NOT NULL DEFAULT 'disponible',
    UNIQUE KEY uq_slot (fecha, hora_inicio),         -- ← garantía "1 cita por hora"
    CONSTRAINT fk_hor_usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Citas (
    id_cita     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_cliente  INT UNSIGNED NOT NULL,
    id_horario  INT UNSIGNED NOT NULL UNIQUE,        -- 1 cita por horario
    motivo      VARCHAR(300),
    estado      ENUM('pendiente','atendida','cancelada') NOT NULL DEFAULT 'pendiente',
    -- fecha/hora NO se repiten aquí: se obtienen del JOIN con Horarios
    CONSTRAINT fk_cita_cliente  FOREIGN KEY (id_cliente)  REFERENCES Clientes(id_cliente),
    CONSTRAINT fk_cita_horario  FOREIGN KEY (id_horario)  REFERENCES Horarios(id_horario)
);

-- ------------------------------------------------------------
-- CONSULTAS  (registro clínico post-cita)
-- ------------------------------------------------------------

CREATE TABLE Consultas (
    id_consulta     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_expediente   INT UNSIGNED NOT NULL,
    id_cita         INT UNSIGNED NOT NULL UNIQUE,    -- 1 consulta por cita
    diagnostico     TEXT,
    observaciones   TEXT,
    fecha_consulta  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_con_expediente FOREIGN KEY (id_expediente) REFERENCES Expedientes(id_expediente),
    CONSTRAINT fk_con_cita       FOREIGN KEY (id_cita)       REFERENCES Citas(id_cita)
);

-- ------------------------------------------------------------
-- TRATAMIENTOS
-- ------------------------------------------------------------

CREATE TABLE Tratamientos (
    id_tratamiento  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    descripcion     TEXT,
    costo           DECIMAL(10,2) NOT NULL DEFAULT 0.00
);

CREATE TABLE Consulta_Tratamiento (
    id_consulta_tratamiento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_consulta             INT UNSIGNED NOT NULL,
    id_tratamiento          INT UNSIGNED NOT NULL,
    cantidad                TINYINT UNSIGNED NOT NULL DEFAULT 1,
    observaciones           VARCHAR(300),
    CONSTRAINT fk_ct_consulta    FOREIGN KEY (id_consulta)    REFERENCES Consultas(id_consulta),
    CONSTRAINT fk_ct_tratamiento FOREIGN KEY (id_tratamiento) REFERENCES Tratamientos(id_tratamiento)
);

-- ------------------------------------------------------------
-- INVENTARIO  (control interno, no se factura)
-- ------------------------------------------------------------

CREATE TABLE Inventario (
    id_producto     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    descripcion     TEXT,
    stock           INT UNSIGNED NOT NULL DEFAULT 0,
    precio_compra   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    fecha_vencimiento DATE
);

-- ------------------------------------------------------------
-- FACTURAS Y DETALLE
-- Vinculadas a la consulta que originó el cobro
-- ------------------------------------------------------------

CREATE TABLE Facturas (
    id_factura  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_cliente  INT UNSIGNED NOT NULL,
    id_consulta INT UNSIGNED NOT NULL UNIQUE,        -- ← FK añadida
    fecha       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    impuesto    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_fac_cliente  FOREIGN KEY (id_cliente)  REFERENCES Clientes(id_cliente),
    CONSTRAINT fk_fac_consulta FOREIGN KEY (id_consulta) REFERENCES Consultas(id_consulta)
);

CREATE TABLE Detalle_Factura (
    id_detalle      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_factura      INT UNSIGNED NOT NULL,
    id_tratamiento  INT UNSIGNED NOT NULL,
    cantidad        TINYINT UNSIGNED NOT NULL DEFAULT 1,
    precio          DECIMAL(10,2) NOT NULL,          -- precio al momento del cobro
    CONSTRAINT fk_df_factura      FOREIGN KEY (id_factura)     REFERENCES Facturas(id_factura),
    CONSTRAINT fk_df_tratamiento  FOREIGN KEY (id_tratamiento) REFERENCES Tratamientos(id_tratamiento)
);

-- ------------------------------------------------------------
-- CAJA  (ingresos por facturas + egresos operativos)
-- ------------------------------------------------------------

CREATE TABLE Caja (
    id_movimiento   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT UNSIGNED NOT NULL,           -- quien registró el movimiento
    id_factura      INT UNSIGNED NULL,               -- ← FK añadida (NULL si es egreso)
    fecha           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_movimiento ENUM('ingreso','egreso') NOT NULL,
    monto           DECIMAL(10,2) NOT NULL,
    descripcion     VARCHAR(300),
    CONSTRAINT fk_caja_usuario  FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    CONSTRAINT fk_caja_factura  FOREIGN KEY (id_factura) REFERENCES Facturas(id_factura)
);

-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO Roles (nombre_rol) VALUES
    ('Admin'),
    ('Odontólogo'),
    ('Recepcionista');
