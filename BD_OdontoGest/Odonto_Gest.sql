-- ============================================================
--  BD: OdontoGest — Clínica Dental Paz
--  Versión: 2.0  |  UTH · Programación Móvil II · 2-2026
--  18 tablas · 5 módulos
-- ============================================================

CREATE DATABASE IF NOT EXISTS odonto_gest
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE odonto_gest;

-- ============================================================
--  MÓDULO 1: SEGURIDAD Y RBAC
-- ============================================================

CREATE TABLE roles (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(50)     NOT NULL UNIQUE COMMENT 'Administrador | Odontólogo | Recepción',
    descripcion VARCHAR(200),
    estado      ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE permisos (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    modulo      ENUM('agenda','expedientes','facturacion','inventario','seguridad')
                                NOT NULL,
    accion      ENUM('ver','crear','editar','eliminar') NOT NULL,
    descripcion VARCHAR(200),
    UNIQUE KEY uq_modulo_accion (modulo, accion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE rol_permisos (
    rol_id      INT UNSIGNED    NOT NULL,
    permiso_id  INT UNSIGNED    NOT NULL,
    PRIMARY KEY (rol_id, permiso_id),
    CONSTRAINT fk_rp_rol     FOREIGN KEY (rol_id)     REFERENCES roles(id)    ON DELETE CASCADE,
    CONSTRAINT fk_rp_permiso FOREIGN KEY (permiso_id) REFERENCES permisos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE usuarios (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    rol_id          INT UNSIGNED    NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    apellido        VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL COMMENT 'bcrypt',
    telefono        VARCHAR(20),
    estado          ENUM('activo','inactivo','suspendido') NOT NULL DEFAULT 'activo',
    ultimo_acceso   DATETIME,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_usr_rol FOREIGN KEY (rol_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  MÓDULO 2: PACIENTES Y EXPEDIENTES
-- ============================================================

CREATE TABLE pacientes (
    id                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre               VARCHAR(100) NOT NULL,
    apellido             VARCHAR(100) NOT NULL,
    fecha_nacimiento     DATE,
    sexo                 ENUM('M','F'),
    telefono             VARCHAR(20),
    telefono_emergencia  VARCHAR(20),
    email                VARCHAR(150),
    direccion            VARCHAR(300),
    numero_identidad     VARCHAR(50)  UNIQUE,
    estado               ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
    created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE expedientes (
    id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    paciente_id             INT UNSIGNED NOT NULL UNIQUE COMMENT '1 expediente por paciente',
    tipo_sangre             VARCHAR(5),
    alergias                TEXT,
    enfermedades            TEXT         COMMENT 'Enfermedades crónicas o sistémicas',
    medicamentos_actuales   TEXT,
    antecedentes_familiares TEXT,
    observaciones           TEXT,
    created_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_exp_paciente FOREIGN KEY (paciente_id) REFERENCES pacientes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE odontograma (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    expediente_id   INT UNSIGNED    NOT NULL,
    odontologo_id   INT UNSIGNED    NOT NULL,
    pieza_dental    VARCHAR(5)      NOT NULL COMMENT 'FDI: 11-48 permanente / A-T temporal',
    cara_dental     ENUM('oclusal','vestibular','lingual','mesial','distal','completa')
                                    NOT NULL DEFAULT 'completa',
    condicion       ENUM('sano','caries','extraccion','endodoncia','corona','implante',
                         'obturacion','ausente','fractura')
                                    NOT NULL,
    color_codigo    VARCHAR(10)     COMMENT 'HEX para representación visual en la app',
    descripcion     TEXT,
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_odonto_exp       FOREIGN KEY (expediente_id)  REFERENCES expedientes(id),
    CONSTRAINT fk_odonto_odontologo FOREIGN KEY (odontologo_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE historial_tratamientos (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    expediente_id   INT UNSIGNED    NOT NULL,
    odontologo_id   INT UNSIGNED    NOT NULL,
    servicio_id     INT UNSIGNED    NOT NULL,
    pieza_dental    VARCHAR(5)      COMMENT 'Pieza tratada, nulo si es tratamiento general',
    descripcion     TEXT,
    observaciones   TEXT,
    fecha_inicio    DATE            NOT NULL,
    fecha_fin       DATE,
    estado          ENUM('en_curso','completado','suspendido') NOT NULL DEFAULT 'en_curso',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ht_expediente  FOREIGN KEY (expediente_id) REFERENCES expedientes(id),
    CONSTRAINT fk_ht_odontologo  FOREIGN KEY (odontologo_id) REFERENCES usuarios(id),
    CONSTRAINT fk_ht_servicio    FOREIGN KEY (servicio_id)   REFERENCES servicios_catalogo(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  MÓDULO 3: AGENDA INTELIGENTE
-- ============================================================

CREATE TABLE odontologos (
    id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id       INT UNSIGNED NOT NULL UNIQUE,
    especialidad     ENUM('general','ortodoncia','endodoncia','periodoncia','cirugia')
                                  NOT NULL DEFAULT 'general',
    numero_licencia  VARCHAR(50),
    color_agenda     VARCHAR(10)  COMMENT 'HEX para visualización en agenda',
    estado           ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
    CONSTRAINT fk_od_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sillones (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    numero      VARCHAR(20)     NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    estado      ENUM('disponible','mantenimiento','deshabilitado') NOT NULL DEFAULT 'disponible'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE citas (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    paciente_id     INT UNSIGNED    NOT NULL,
    odontologo_id   INT UNSIGNED    NOT NULL,
    sillon_id       INT UNSIGNED    NOT NULL,
    fecha           DATE            NOT NULL,
    hora_inicio     TIME            NOT NULL,
    hora_fin        TIME            NOT NULL,
    motivo          VARCHAR(300),
    estado          ENUM('programada','confirmada','atendida','cancelada','no_asistio')
                                    NOT NULL DEFAULT 'programada',
    notas           TEXT,
    registrado_por  INT UNSIGNED    NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Evitar colisiones: un odontólogo no puede tener 2 citas en el mismo slot
    UNIQUE KEY uq_odontologo_slot (odontologo_id, fecha, hora_inicio),
    -- Un sillón no puede ser ocupado dos veces en el mismo slot
    UNIQUE KEY uq_sillon_slot     (sillon_id, fecha, hora_inicio),
    CONSTRAINT fk_cita_paciente    FOREIGN KEY (paciente_id)    REFERENCES pacientes(id),
    CONSTRAINT fk_cita_odontologo  FOREIGN KEY (odontologo_id)  REFERENCES odontologos(id),
    CONSTRAINT fk_cita_sillon      FOREIGN KEY (sillon_id)      REFERENCES sillones(id),
    CONSTRAINT fk_cita_registrado  FOREIGN KEY (registrado_por) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  MÓDULO 4: FACTURACIÓN Y COBROS
-- ============================================================

CREATE TABLE servicios_catalogo (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(150)    NOT NULL,
    descripcion TEXT,
    categoria   ENUM('preventivo','restaurativo','quirurgico','estetico','ortodoncia')
                                NOT NULL,
    precio_base DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    estado      ENUM('activo','inactivo') NOT NULL DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE facturas (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    paciente_id     INT UNSIGNED    NOT NULL,
    cita_id         INT UNSIGNED,
    fecha_emision   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal        DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    descuento       DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    impuesto        DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    total           DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    estado          ENUM('pendiente','pagada_parcial','pagada_total','anulada')
                                    NOT NULL DEFAULT 'pendiente',
    notas           TEXT,
    registrado_por  INT UNSIGNED    NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fac_paciente    FOREIGN KEY (paciente_id)   REFERENCES pacientes(id),
    CONSTRAINT fk_fac_cita        FOREIGN KEY (cita_id)       REFERENCES citas(id),
    CONSTRAINT fk_fac_registrado  FOREIGN KEY (registrado_por) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE detalle_factura (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    factura_id      INT UNSIGNED    NOT NULL,
    servicio_id     INT UNSIGNED    NOT NULL,
    descripcion     VARCHAR(300),
    cantidad        TINYINT UNSIGNED NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2)   NOT NULL,
    subtotal        DECIMAL(10,2)   NOT NULL COMMENT 'cantidad × precio_unitario',
    CONSTRAINT fk_df_factura   FOREIGN KEY (factura_id)  REFERENCES facturas(id),
    CONSTRAINT fk_df_servicio  FOREIGN KEY (servicio_id) REFERENCES servicios_catalogo(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE abonos (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    factura_id      INT UNSIGNED    NOT NULL,
    monto           DECIMAL(10,2)   NOT NULL,
    fecha           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago     ENUM('efectivo','tarjeta','transferencia','otro') NOT NULL DEFAULT 'efectivo',
    referencia      VARCHAR(100)    COMMENT 'Número de comprobante o referencia bancaria',
    notas           TEXT,
    registrado_por  INT UNSIGNED    NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_abo_factura     FOREIGN KEY (factura_id)    REFERENCES facturas(id),
    CONSTRAINT fk_abo_registrado  FOREIGN KEY (registrado_por) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cuentas_por_cobrar (
    id                INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    paciente_id       INT UNSIGNED    NOT NULL,
    factura_id        INT UNSIGNED    NOT NULL UNIQUE,
    total_factura     DECIMAL(10,2)   NOT NULL,
    total_abonado     DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    saldo_pendiente   DECIMAL(10,2)   NOT NULL COMMENT 'total_factura - total_abonado',
    estado            ENUM('al_dia','en_mora','saldada') NOT NULL DEFAULT 'al_dia',
    fecha_vencimiento DATE,
    updated_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_cxc_paciente FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
    CONSTRAINT fk_cxc_factura  FOREIGN KEY (factura_id)  REFERENCES facturas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  MÓDULO 5: INVENTARIO DE INSUMOS
-- ============================================================

CREATE TABLE categorias_insumo (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100)    NOT NULL UNIQUE,
    descripcion TEXT,
    estado      ENUM('activa','inactiva') NOT NULL DEFAULT 'activa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE proveedores (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(150)    NOT NULL,
    contacto    VARCHAR(100),
    telefono    VARCHAR(20),
    email       VARCHAR(150),
    direccion   VARCHAR(300),
    estado      ENUM('activo','inactivo') NOT NULL DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE insumos (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    categoria_id    INT UNSIGNED    NOT NULL,
    proveedor_id    INT UNSIGNED,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     TEXT,
    unidad_medida   ENUM('unidad','caja','frasco','par','rollo','litro','gramo','otro')
                                    NOT NULL DEFAULT 'unidad',
    stock_actual    INT UNSIGNED    NOT NULL DEFAULT 0,
    stock_minimo    INT UNSIGNED    NOT NULL DEFAULT 5 COMMENT 'Umbral de alerta crítica',
    precio_unitario DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    fecha_caducidad DATE,
    lote            VARCHAR(50),
    estado          ENUM('disponible','agotado','descontinuado') NOT NULL DEFAULT 'disponible',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ins_categoria  FOREIGN KEY (categoria_id)  REFERENCES categorias_insumo(id),
    CONSTRAINT fk_ins_proveedor  FOREIGN KEY (proveedor_id)  REFERENCES proveedores(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE movimientos_inventario (
    id                INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    insumo_id         INT UNSIGNED    NOT NULL,
    tipo              ENUM('entrada','salida','ajuste','merma','caducado') NOT NULL,
    cantidad          INT             NOT NULL COMMENT 'Negativo en salidas/mermas',
    stock_anterior    INT UNSIGNED    NOT NULL,
    stock_resultante  INT UNSIGNED    NOT NULL,
    cita_id           INT UNSIGNED    COMMENT 'Referencia si la salida fue por una cita',
    descripcion       TEXT,
    usuario_id        INT UNSIGNED    NOT NULL,
    fecha             DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mov_insumo   FOREIGN KEY (insumo_id)  REFERENCES insumos(id),
    CONSTRAINT fk_mov_cita     FOREIGN KEY (cita_id)    REFERENCES citas(id),
    CONSTRAINT fk_mov_usuario  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE alertas_inventario (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    insumo_id       INT UNSIGNED    NOT NULL,
    tipo_alerta     ENUM('stock_critico','proximo_a_vencer','caducado') NOT NULL,
    mensaje         TEXT            NOT NULL,
    estado          ENUM('activa','revisada','resuelta') NOT NULL DEFAULT 'activa',
    fecha_generada  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revisada_por    INT UNSIGNED,
    fecha_revision  DATETIME,
    CONSTRAINT fk_ale_insumo     FOREIGN KEY (insumo_id)     REFERENCES insumos(id),
    CONSTRAINT fk_ale_revisado   FOREIGN KEY (revisada_por)  REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  DATOS INICIALES
-- ============================================================

INSERT INTO roles (nombre, descripcion) VALUES
    ('Administrador', 'Acceso total al sistema'),
    ('Odontólogo',    'Acceso a expedientes, agenda y tratamientos'),
    ('Recepción',     'Gestión de citas, pacientes y facturación');

INSERT INTO categorias_insumo (nombre, descripcion) VALUES
    ('Anestésicos',    'Anestesia local y materiales relacionados'),
    ('Resinas',        'Resinas compuestas y adhesivos'),
    ('Descartables',   'Guantes, mascarillas, baberos y artículos de uso único'),
    ('Instrumental',   'Instrumentos dentales reutilizables'),
    ('Radiología',     'Películas radiográficas y materiales de imagen');

INSERT INTO sillones (numero, descripcion) VALUES
    ('S-01', 'Sillón principal — Consultorio 1'),
    ('S-02', 'Sillón principal — Consultorio 2'),
    ('S-03', 'Sillón de urgencias');

INSERT INTO servicios_catalogo (nombre, descripcion, categoria, precio_base) VALUES
    ('Limpieza dental',     'Profilaxis y detartraje',                'preventivo',   350.00),
    ('Extracción simple',   'Extracción de pieza sin complicaciones', 'quirurgico',   500.00),
    ('Endodoncia',          'Tratamiento de conducto radicular',      'restaurativo', 1800.00),
    ('Corona porcelana',    'Corona de porcelana sobre metal',        'restaurativo', 3500.00),
    ('Blanqueamiento',      'Blanqueamiento dental con peróxido',     'estetico',     2200.00),
    ('Ortodoncia mensual',  'Control mensual de aparatos ortodónticos','ortodoncia',   600.00);
