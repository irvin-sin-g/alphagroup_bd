-- ============================================================================
-- ALPHA GROUP - BASE DE DATOS ESTANDARIZADA DE REFERENCIA
-- ============================================================================
-- PROPÓSITO
--   Esquema de referencia para los proyectos
--
-- ============================================================================

CREATE DATABASE alphagroup_estandar
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE alphagroup_estandar;

-- ============================================================================
-- 1. CLIENTES
-- ============================================================================

CREATE TABLE clientes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(30) NULL,
    correo VARCHAR(150) NULL,
    foto LONGBLOB NULL,
    foto_tipo_contenido VARCHAR(100) NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    INDEX idx_clientes_nombre (nombre, apellidos),
    INDEX idx_clientes_correo (correo),
    INDEX idx_clientes_telefono (telefono),
    INDEX idx_clientes_activo (activo)
) ENGINE=InnoDB;

-- ============================================================================
-- 2. USUARIOS Y ROLES
-- ============================================================================
-- Rol estándar de integración:
--   ADMIN, RECEPCIONISTA, CLIENTE
-- ============================================================================

CREATE TABLE usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NULL,
    username VARCHAR(80) NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(30) NOT NULL,
    cliente_id BIGINT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uk_usuarios_correo UNIQUE (correo),
    CONSTRAINT uk_usuarios_username UNIQUE (username),
    CONSTRAINT uk_usuarios_cliente UNIQUE (cliente_id),

    CONSTRAINT fk_usuarios_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id),

    CONSTRAINT chk_usuarios_identificador
        CHECK (correo IS NOT NULL OR username IS NOT NULL),

    CONSTRAINT chk_usuarios_rol
        CHECK (rol IN ('ADMIN', 'RECEPCIONISTA', 'CLIENTE')),

    INDEX idx_usuarios_rol (rol),
    INDEX idx_usuarios_activo (activo)
) ENGINE=InnoDB;

-- ============================================================================
-- 3. GIMNASIO / MEMBRESÍAS
-- ============================================================================

CREATE TABLE membresias (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    duracion_dias INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT chk_membresias_duracion CHECK (duracion_dias > 0),
    CONSTRAINT chk_membresias_precio CHECK (precio >= 0),

    INDEX idx_membresias_activo (activo)
) ENGINE=InnoDB;

CREATE TABLE cliente_membresias (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    membresia_id BIGINT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    precio_pagado DECIMAL(10,2) NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT fk_cliente_membresias_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id),

    CONSTRAINT fk_cliente_membresias_membresia
        FOREIGN KEY (membresia_id)
        REFERENCES membresias(id),

    CONSTRAINT chk_cliente_membresias_fechas
        CHECK (fecha_fin >= fecha_inicio),

    CONSTRAINT chk_cliente_membresias_precio
        CHECK (precio_pagado >= 0),

    INDEX idx_cliente_membresias_cliente (cliente_id),
    INDEX idx_cliente_membresias_vigencia (fecha_inicio, fecha_fin),
    INDEX idx_cliente_membresias_activo (activo)
) ENGINE=InnoDB;

-- ============================================================================
-- 4. INSTRUCTORES
-- ============================================================================

CREATE TABLE instructores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(30) NULL,
    correo VARCHAR(150) NULL,
    foto LONGBLOB NULL,
    foto_tipo_contenido VARCHAR(100) NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    INDEX idx_instructores_nombre (nombre, apellidos),
    INDEX idx_instructores_correo (correo),
    INDEX idx_instructores_activo (activo)
) ENGINE=InnoDB;

CREATE TABLE instructor_especialidades (
    instructor_id BIGINT NOT NULL,
    tipo_servicio VARCHAR(20) NOT NULL,

    PRIMARY KEY (instructor_id, tipo_servicio),

    CONSTRAINT fk_instructor_especialidades_instructor
        FOREIGN KEY (instructor_id)
        REFERENCES instructores(id),

    CONSTRAINT chk_instructor_especialidades_tipo
        CHECK (tipo_servicio IN ('INDOOR', 'BARRE'))
) ENGINE=InnoDB;

-- ============================================================================
-- 5. PLANES INDOOR CYCLING / BARRE
-- ============================================================================

CREATE TABLE planes_reserva (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo_servicio VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    duracion_dias INT NOT NULL,
    cantidad_clases INT NULL,
    max_clases_semana INT NULL,
    incluye_gym TINYINT(1) NOT NULL DEFAULT 0,
    precio DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT chk_planes_reserva_tipo
        CHECK (tipo_servicio IN ('INDOOR', 'BARRE')),

    CONSTRAINT chk_planes_reserva_duracion
        CHECK (duracion_dias > 0),

    CONSTRAINT chk_planes_reserva_cantidad
        CHECK (cantidad_clases IS NULL OR cantidad_clases > 0),

    CONSTRAINT chk_planes_reserva_semana
        CHECK (max_clases_semana IS NULL OR max_clases_semana > 0),

    CONSTRAINT chk_planes_reserva_precio
        CHECK (precio >= 0),

    INDEX idx_planes_reserva_tipo (tipo_servicio),
    INDEX idx_planes_reserva_activo (activo)
) ENGINE=InnoDB;

CREATE TABLE clientes_planes_reserva (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    plan_id BIGINT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    precio_pagado DECIMAL(10,2) NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT fk_clientes_planes_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id),

    CONSTRAINT fk_clientes_planes_plan
        FOREIGN KEY (plan_id)
        REFERENCES planes_reserva(id),

    CONSTRAINT chk_clientes_planes_fechas
        CHECK (fecha_fin >= fecha_inicio),

    CONSTRAINT chk_clientes_planes_precio
        CHECK (precio_pagado >= 0),

    INDEX idx_clientes_planes_cliente (cliente_id),
    INDEX idx_clientes_planes_vigencia (fecha_inicio, fecha_fin),
    INDEX idx_clientes_planes_activo (activo)
) ENGINE=InnoDB;

-- ============================================================================
-- 6. PROGRAMACIÓN DE CLASES
-- ============================================================================

CREATE TABLE grupos_clase (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo_servicio VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    instructor_id BIGINT NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    cupo_maximo INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT fk_grupos_clase_instructor
        FOREIGN KEY (instructor_id)
        REFERENCES instructores(id),

    CONSTRAINT chk_grupos_clase_tipo
        CHECK (tipo_servicio IN ('INDOOR', 'BARRE')),

    CONSTRAINT chk_grupos_clase_horario
        CHECK (hora_fin > hora_inicio),

    CONSTRAINT chk_grupos_clase_cupo
        CHECK (cupo_maximo > 0),

    CONSTRAINT chk_grupos_clase_fechas
        CHECK (fecha_fin >= fecha_inicio),

    INDEX idx_grupos_clase_tipo (tipo_servicio),
    INDEX idx_grupos_clase_instructor (instructor_id),
    INDEX idx_grupos_clase_activo (activo)
) ENGINE=InnoDB;

CREATE TABLE grupo_clase_dias (
    grupo_id BIGINT NOT NULL,
    dia_semana VARCHAR(15) NOT NULL,

    PRIMARY KEY (grupo_id, dia_semana),

    CONSTRAINT fk_grupo_clase_dias_grupo
        FOREIGN KEY (grupo_id)
        REFERENCES grupos_clase(id),

    CONSTRAINT chk_grupo_clase_dias_dia
        CHECK (
            dia_semana IN (
                'MONDAY', 'TUESDAY', 'WEDNESDAY',
                'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
            )
        )
) ENGINE=InnoDB;

CREATE TABLE sesiones_clase (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    grupo_id BIGINT NOT NULL,
    instructor_id BIGINT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    cupo_maximo INT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA',
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uk_sesiones_clase_grupo_fecha
        UNIQUE (grupo_id, fecha),

    CONSTRAINT fk_sesiones_clase_grupo
        FOREIGN KEY (grupo_id)
        REFERENCES grupos_clase(id),

    CONSTRAINT fk_sesiones_clase_instructor
        FOREIGN KEY (instructor_id)
        REFERENCES instructores(id),

    CONSTRAINT chk_sesiones_clase_horario
        CHECK (hora_fin > hora_inicio),

    CONSTRAINT chk_sesiones_clase_cupo
        CHECK (cupo_maximo > 0),

    CONSTRAINT chk_sesiones_clase_estado
        CHECK (estado IN ('PROGRAMADA', 'CANCELADA')),

    INDEX idx_sesiones_clase_fecha (fecha),
    INDEX idx_sesiones_clase_estado (estado),
    INDEX idx_sesiones_clase_activo (activo)
) ENGINE=InnoDB;

CREATE TABLE inscripciones_grupo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    grupo_id BIGINT NOT NULL,
    fecha_inscripcion DATETIME NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uk_inscripciones_grupo_cliente_grupo
        UNIQUE (cliente_id, grupo_id),

    CONSTRAINT fk_inscripciones_grupo_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id),

    CONSTRAINT fk_inscripciones_grupo_grupo
        FOREIGN KEY (grupo_id)
        REFERENCES grupos_clase(id),

    INDEX idx_inscripciones_grupo_cliente (cliente_id),
    INDEX idx_inscripciones_grupo_grupo (grupo_id),
    INDEX idx_inscripciones_grupo_activo (activo)
) ENGINE=InnoDB;

CREATE TABLE reservas_clases (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    sesion_id BIGINT NOT NULL,
    cliente_plan_reserva_id BIGINT NOT NULL,
    fecha_registro DATETIME NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'RESERVADA',
    origen VARCHAR(20) NOT NULL DEFAULT 'INDIVIDUAL',
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uk_reservas_clases_cliente_sesion
        UNIQUE (cliente_id, sesion_id),

    CONSTRAINT fk_reservas_clases_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id),

    CONSTRAINT fk_reservas_clases_sesion
        FOREIGN KEY (sesion_id)
        REFERENCES sesiones_clase(id),

    CONSTRAINT fk_reservas_clases_cliente_plan
        FOREIGN KEY (cliente_plan_reserva_id)
        REFERENCES clientes_planes_reserva(id),

    CONSTRAINT chk_reservas_clases_estado
        CHECK (estado IN ('RESERVADA', 'CANCELADA')),

    CONSTRAINT chk_reservas_clases_origen
        CHECK (origen IN ('INDIVIDUAL', 'GRUPO')),

    INDEX idx_reservas_clases_cliente (cliente_id),
    INDEX idx_reservas_clases_sesion (sesion_id),
    INDEX idx_reservas_clases_estado (estado),
    INDEX idx_reservas_clases_activo (activo)
) ENGINE=InnoDB;

-- ============================================================================
-- 7. PÁDEL
-- ============================================================================

CREATE TABLE canchas_padel (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uk_canchas_padel_nombre UNIQUE (nombre),
    INDEX idx_canchas_padel_activo (activo)
) ENGINE=InnoDB;

CREATE TABLE configuracion_padel (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tarifa_dia DECIMAL(10,2) NOT NULL,
    tarifa_noche DECIMAL(10,2) NOT NULL,
    precio_pala DECIMAL(10,2) NOT NULL,
    precio_paquete_pelotas DECIMAL(10,2) NOT NULL,
    hora_apertura TIME NOT NULL,
    hora_cambio_tarifa TIME NOT NULL,
    hora_cierre TIME NOT NULL,

    CONSTRAINT chk_configuracion_padel_tarifas
        CHECK (
            tarifa_dia >= 0
            AND tarifa_noche >= 0
            AND precio_pala >= 0
            AND precio_paquete_pelotas >= 0
        ),

    CONSTRAINT chk_configuracion_padel_horario
        CHECK (
            hora_cambio_tarifa >= hora_apertura
            AND hora_cierre > hora_apertura
        )
) ENGINE=InnoDB;

CREATE TABLE reservas_padel (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    cancha_id BIGINT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    cantidad_palas INT NOT NULL DEFAULT 0,
    paquetes_pelotas INT NOT NULL DEFAULT 0,
    precio_cancha DECIMAL(10,2) NOT NULL,
    precio_extras DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    fecha_registro DATETIME NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'RESERVADA',
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT fk_reservas_padel_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id),

    CONSTRAINT fk_reservas_padel_cancha
        FOREIGN KEY (cancha_id)
        REFERENCES canchas_padel(id),

    CONSTRAINT chk_reservas_padel_horario
        CHECK (hora_fin > hora_inicio),

    CONSTRAINT chk_reservas_padel_extras
        CHECK (cantidad_palas >= 0 AND paquetes_pelotas >= 0),

    CONSTRAINT chk_reservas_padel_importes
        CHECK (precio_cancha >= 0 AND precio_extras >= 0 AND total >= 0),

    CONSTRAINT chk_reservas_padel_estado
        CHECK (estado IN ('RESERVADA', 'CANCELADA')),

    INDEX idx_reservas_padel_cliente (cliente_id),
    INDEX idx_reservas_padel_disponibilidad (cancha_id, fecha, hora_inicio, hora_fin),
    INDEX idx_reservas_padel_estado (estado),
    INDEX idx_reservas_padel_activo (activo)
) ENGINE=InnoDB;

-- ============================================================================
-- 8. INVENTARIO / CATÁLOGO DE PRODUCTOS
-- ============================================================================
-- Tabla producto unificada de referencia:
--   - POS utiliza nombre, descripción, precio_venta y activo.
--   - Inventario utiliza categoría, stock, costo, mínimo, baja y versión.
-- ============================================================================

CREATE TABLE categorias (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    descripcion VARCHAR(120) NULL,
    es_de_venta TINYINT(1) NOT NULL DEFAULT 1,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uk_categorias_nombre UNIQUE (nombre),
    INDEX idx_categorias_activo (activo),
    INDEX idx_categorias_venta (es_de_venta)
) ENGINE=InnoDB;

CREATE TABLE productos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(255) NULL,
    categoria_id BIGINT NULL,
    stock INT NOT NULL DEFAULT 0,
    costo_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    stock_minimo INT NOT NULL DEFAULT 0,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    motivo_baja VARCHAR(30) NULL,
    fecha_baja DATETIME NULL,
    version BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT uk_productos_nombre UNIQUE (nombre),

    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(id),

    CONSTRAINT chk_productos_stock
        CHECK (stock >= 0 AND stock_minimo >= 0),

    CONSTRAINT chk_productos_importes
        CHECK (costo_unitario >= 0 AND precio_venta >= 0),

    INDEX idx_productos_categoria (categoria_id),
    INDEX idx_productos_activo (activo),
    INDEX idx_productos_stock (stock, stock_minimo)
) ENGINE=InnoDB;

CREATE TABLE movimientos_inventario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad INT NOT NULL,
    stock_resultante INT NOT NULL,
    fecha DATETIME NOT NULL,
    usuario_id BIGINT NOT NULL,
    motivo VARCHAR(200) NULL,

    CONSTRAINT fk_movimientos_inventario_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(id),

    CONSTRAINT fk_movimientos_inventario_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id),

    CONSTRAINT chk_movimientos_inventario_tipo
        CHECK (tipo IN ('ENTRADA', 'SALIDA_VENTA', 'MERMA')),

    CONSTRAINT chk_movimientos_inventario_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT chk_movimientos_inventario_stock
        CHECK (stock_resultante >= 0),

    INDEX idx_movimientos_inventario_producto (producto_id),
    INDEX idx_movimientos_inventario_usuario (usuario_id),
    INDEX idx_movimientos_inventario_fecha (fecha),
    INDEX idx_movimientos_inventario_tipo (tipo)
) ENGINE=InnoDB;

-- ============================================================================
-- 9. PUNTO DE VENTA
-- ============================================================================

CREATE TABLE ventas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME NOT NULL,
    metodo_pago VARCHAR(30) NOT NULL,
    total DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_ventas_metodo_pago
        CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA')),

    CONSTRAINT chk_ventas_total
        CHECK (total >= 0),

    INDEX idx_ventas_fecha (fecha),
    INDEX idx_ventas_metodo_pago (metodo_pago)
) ENGINE=InnoDB;

CREATE TABLE detalle_ventas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    nombre_producto VARCHAR(120) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_detalle_ventas_venta
        FOREIGN KEY (venta_id)
        REFERENCES ventas(id),

    CONSTRAINT fk_detalle_ventas_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(id),

    CONSTRAINT chk_detalle_ventas_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT chk_detalle_ventas_importes
        CHECK (precio_unitario >= 0 AND subtotal >= 0),

    INDEX idx_detalle_ventas_venta (venta_id),
    INDEX idx_detalle_ventas_producto (producto_id)
) ENGINE=InnoDB;

-- ============================================================================
-- 10. CITAS - FISIOTERAPIA / MADEROTERAPIA
-- ============================================================================
-- cliente_id es opcional para permitir que el subsistema funcione de forma
-- independiente. nombre_completo y telefono quedan como snapshot operativo.
-- ============================================================================

CREATE TABLE citas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NULL,
    servicio VARCHAR(30) NOT NULL,
    fecha_hora DATETIME NOT NULL,
    nombre_completo VARCHAR(120) NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    observaciones VARCHAR(500) NULL,

    -- Fisioterapia
    zona_afectada VARCHAR(120) NULL,
    motivo_consulta VARCHAR(500) NULL,
    nivel_dolor INT NULL,
    cirugias_lesiones VARCHAR(500) NULL,

    -- Maderoterapia
    zona_trabajar VARCHAR(120) NULL,
    objetivo VARCHAR(20) NULL,
    condiciones_medicas VARCHAR(500) NULL,

    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    creada_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT fk_citas_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id),

    CONSTRAINT chk_citas_servicio
        CHECK (servicio IN ('FISIOTERAPIA', 'MADEROTERAPIA')),

    CONSTRAINT chk_citas_estado
        CHECK (estado IN ('PENDIENTE', 'CONFIRMADA', 'ATENDIDA', 'CANCELADA')),

    CONSTRAINT chk_citas_objetivo
        CHECK (objetivo IS NULL OR objetivo IN ('REDUCTIVO', 'RELAJANTE', 'ESTETICO')),

    CONSTRAINT chk_citas_nivel_dolor
        CHECK (nivel_dolor IS NULL OR nivel_dolor BETWEEN 0 AND 10),

    INDEX idx_citas_cliente (cliente_id),
    INDEX idx_citas_fecha (fecha_hora),
    INDEX idx_citas_servicio (servicio),
    INDEX idx_citas_estado (estado),
    INDEX idx_citas_activo (activo)
) ENGINE=InnoDB;

-- ============================================================================
-- 11. GUARDERÍA
-- ============================================================================
-- cliente_id es opcional para permitir operación independiente del subsistema.
-- ============================================================================

CREATE TABLE guarderia_registros (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NULL,
    fecha_hora_ingreso DATETIME NOT NULL,
    nombre_menor VARCHAR(120) NOT NULL,
    nombre_entrega VARCHAR(120) NOT NULL,
    nombre_recoge VARCHAR(120) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'EN_GUARDERIA',
    fecha_hora_egreso DATETIME NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT fk_guarderia_registros_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id),

    CONSTRAINT chk_guarderia_registros_estado
        CHECK (estado IN ('EN_GUARDERIA', 'EGRESADO')),

    CONSTRAINT chk_guarderia_registros_egreso
        CHECK (
            fecha_hora_egreso IS NULL
            OR fecha_hora_egreso >= fecha_hora_ingreso
        ),

    INDEX idx_guarderia_registros_cliente (cliente_id),
    INDEX idx_guarderia_registros_ingreso (fecha_hora_ingreso),
    INDEX idx_guarderia_registros_estado (estado),
    INDEX idx_guarderia_registros_activo (activo)
) ENGINE=InnoDB;

-- ============================================================================
-- 12. DATOS BASE DE REFERENCIA
-- Datos ficticios / catálogos.
-- ============================================================================

INSERT INTO canchas_padel (nombre, activo)
VALUES
    ('Cancha 1', 1),
    ('Cancha 2', 1);

INSERT INTO configuracion_padel (
    tarifa_dia,
    tarifa_noche,
    precio_pala,
    precio_paquete_pelotas,
    hora_apertura,
    hora_cambio_tarifa,
    hora_cierre
)
VALUES (
    150.00,
    300.00,
    50.00,
    50.00,
    '07:00:00',
    '17:00:00',
    '23:00:00'
);

INSERT INTO categorias (
    nombre,
    descripcion,
    es_de_venta,
    activo
)
VALUES
    ('Productos de venta', 'Productos destinados al punto de venta.', 1, 1),
    ('Gimnasio', 'Material y equipo de gimnasio.', 0, 1),
    ('Pádel', 'Material y equipo de Pádel.', 0, 1),
    ('Indoor Cycling', 'Material y equipo de Indoor Cycling.', 0, 1),
    ('Barre', 'Material y equipo de Barre.', 0, 1),
    ('Fisioterapia', 'Material utilizado en fisioterapia.', 0, 1),
    ('Maderoterapia', 'Material utilizado en maderoterapia.', 0, 1),
    ('Guardería', 'Material utilizado en guardería.', 0, 1);

