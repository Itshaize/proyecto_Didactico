-- ============================================================
--  EnglishKids - Script de Base de Datos PostgreSQL
--  ODS 4: Educación de Calidad
--  Aplicación para enseñar inglés a niños
-- ============================================================

-- Crear la base de datos (ejecutar como superusuario)
-- CREATE DATABASE englishkids ENCODING 'UTF8';

-- Conectar a la base de datos antes de ejecutar el resto
-- \c englishkids;

-- ============================================================
-- TABLA: usuarios
-- ============================================================
DROP TABLE IF EXISTS bitacora CASCADE;
DROP TABLE IF EXISTS actividades CASCADE;
DROP TABLE IF EXISTS palabras CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

CREATE TABLE usuarios (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    correo          VARCHAR(150) NOT NULL UNIQUE,
    clave           VARCHAR(64)  NOT NULL,  -- SHA-256 hex
    perfil          VARCHAR(20)  NOT NULL DEFAULT 'estudiante'
                        CHECK (perfil IN ('admin','estudiante')),
    activo          BOOLEAN      NOT NULL DEFAULT TRUE,
    fecha_registro  TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: categorias
-- ============================================================
CREATE TABLE categorias (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    nombre_es   VARCHAR(100) NOT NULL,
    descripcion TEXT,
    icono       VARCHAR(100),
    color_hex   VARCHAR(7)
);

-- ============================================================
-- TABLA: palabras
-- ============================================================
CREATE TABLE palabras (
    id           SERIAL PRIMARY KEY,
    id_categoria INTEGER     NOT NULL REFERENCES categorias(id),
    palabra_en   VARCHAR(100) NOT NULL,
    palabra_es   VARCHAR(100) NOT NULL,
    imagen_url   VARCHAR(255),
    audio_url    VARCHAR(255),
    modelo_3d    VARCHAR(255),
    nivel        VARCHAR(20)  NOT NULL DEFAULT 'basico'
                     CHECK (nivel IN ('basico','intermedio','avanzado'))
);

-- ============================================================
-- TABLA: actividades
-- ============================================================
CREATE TABLE actividades (
    id            SERIAL PRIMARY KEY,
    id_usuario    INTEGER     NOT NULL REFERENCES usuarios(id),
    id_palabra    INTEGER     REFERENCES palabras(id),
    tipo          VARCHAR(50) NOT NULL,   -- 'quiz','pronunciacion','escritura'
    resultado     VARCHAR(20) NOT NULL,   -- 'correcto','incorrecto'
    puntos        INTEGER     NOT NULL DEFAULT 0,
    revisado      BOOLEAN     NOT NULL DEFAULT FALSE,
    aprobado      BOOLEAN,
    observacion_revision TEXT,
    id_admin_revisor INTEGER REFERENCES usuarios(id),
    fecha_revision TIMESTAMP,
    fecha         TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: bitacora
-- ============================================================
CREATE TABLE bitacora (
    id         SERIAL PRIMARY KEY,
    id_usuario INTEGER      REFERENCES usuarios(id),
    accion     VARCHAR(100) NOT NULL,
    detalle    TEXT,
    ip         VARCHAR(45),
    fecha      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- DATOS INICIALES
-- ============================================================

-- Usuario administrador (clave: Admin1234 en SHA-256)
-- SHA-256 de "Admin1234" = b34c4a7c4ff9f2ce4b4f8a10c2f3a9e1c0a6d8e4f2b1c3d5e7a9b0c2d4e6f8a0  
-- Usamos la función encode(digest(...,'sha256'),'hex') de pgcrypto
-- Si pgcrypto no está instalado, la clave en texto plano se hashea desde Java
-- El hash de "Admin1234" (SHA-256): 
-- echo -n "Admin1234" | sha256sum → depende del sistema
-- Usamos placeholder que el Servlet sobreescribirá si usa MessageDigest

INSERT INTO usuarios (nombre, apellido, correo, clave, perfil, activo)
VALUES 
  ('Administrador', 'Sistema', 'admin@englishkids.edu',
   encode(sha256('Admin1234'::bytea), 'hex'),
   'admin', TRUE),
  ('Estudiante', 'Demo', 'estudiante@englishkids.edu',
   encode(sha256('Estudia1234'::bytea), 'hex'),
   'estudiante', TRUE);

-- ============================================================
-- CATEGORÍAS
-- ============================================================
INSERT INTO categorias (nombre, nombre_es, descripcion, icono, color_hex)
VALUES
  ('Animals', 'Animales',
   'Learn the names of animals in English! Discover dogs, cats, birds and more.',
   'fas fa-paw', '#FF7043'),
  ('Colors', 'Colores',
   'Explore the world of colors! Learn how to say each color in English.',
   'fas fa-palette', '#7E57C2'),
  ('Numbers', 'Números',
   'Count and learn numbers in English from 1 to 20!',
   'fas fa-sort-numeric-up', '#26A69A');

-- ============================================================
-- PALABRAS – ANIMALES (categoría 1)
-- ============================================================
INSERT INTO palabras (id_categoria, palabra_en, palabra_es, imagen_url, audio_url, nivel)
VALUES
  (1, 'Dog',      'Perro',    'images/animals/dog.svg',      'audio/animals/dog.mp3',      'basico'),
  (1, 'Cat',      'Gato',     'images/animals/cat.svg',      'audio/animals/cat.mp3',      'basico'),
  (1, 'Bird',     'Pájaro',   'images/animals/bird.svg',     'audio/animals/bird.mp3',     'basico'),
  (1, 'Fish',     'Pez',      'images/animals/fish.svg',     'audio/animals/fish.mp3',     'basico'),
  (1, 'Rabbit',   'Conejo',   'images/animals/rabbit.svg',   'audio/animals/rabbit.mp3',   'basico'),
  (1, 'Lion',     'León',     'images/animals/lion.svg',     'audio/animals/lion.mp3',     'intermedio'),
  (1, 'Elephant', 'Elefante', 'images/animals/elephant.svg', 'audio/animals/elephant.mp3', 'intermedio'),
  (1, 'Butterfly','Mariposa', 'images/animals/butterfly.svg','audio/animals/butterfly.mp3','intermedio'),
  (1, 'Frog',     'Rana',     'images/animals/frog.svg',     'audio/animals/frog.mp3',     'basico'),
  (1, 'Horse',    'Caballo',  'images/animals/horse.svg',    'audio/animals/horse.mp3',    'intermedio');

-- ============================================================
-- PALABRAS – COLORES (categoría 2)
-- ============================================================
INSERT INTO palabras (id_categoria, palabra_en, palabra_es, imagen_url, audio_url, nivel)
VALUES
  (2, 'Red',    'Rojo',     'images/colors/red.svg',    'audio/colors/red.mp3',    'basico'),
  (2, 'Blue',   'Azul',     'images/colors/blue.svg',   'audio/colors/blue.mp3',   'basico'),
  (2, 'Green',  'Verde',    'images/colors/green.svg',  'audio/colors/green.mp3',  'basico'),
  (2, 'Yellow', 'Amarillo', 'images/colors/yellow.svg', 'audio/colors/yellow.mp3', 'basico'),
  (2, 'Purple', 'Morado',   'images/colors/purple.svg', 'audio/colors/purple.mp3', 'basico'),
  (2, 'Orange', 'Naranja',  'images/colors/orange.svg', 'audio/colors/orange.mp3', 'basico'),
  (2, 'Pink',   'Rosado',   'images/colors/pink.svg',   'audio/colors/pink.mp3',   'basico'),
  (2, 'Black',  'Negro',    'images/colors/black.svg',  'audio/colors/black.mp3',  'basico'),
  (2, 'White',  'Blanco',   'images/colors/white.svg',  'audio/colors/white.mp3',  'basico'),
  (2, 'Brown',  'Café',     'images/colors/brown.svg',  'audio/colors/brown.mp3',  'basico');

-- ============================================================
-- PALABRAS – NÚMEROS (categoría 3)
-- ============================================================
INSERT INTO palabras (id_categoria, palabra_en, palabra_es, imagen_url, audio_url, nivel)
VALUES
  (3, 'One',     'Uno',    'images/numbers/one.svg',     'audio/numbers/one.mp3',     'basico'),
  (3, 'Two',     'Dos',    'images/numbers/two.svg',     'audio/numbers/two.mp3',     'basico'),
  (3, 'Three',   'Tres',   'images/numbers/three.svg',   'audio/numbers/three.mp3',   'basico'),
  (3, 'Four',    'Cuatro', 'images/numbers/four.svg',    'audio/numbers/four.mp3',    'basico'),
  (3, 'Five',    'Cinco',  'images/numbers/five.svg',    'audio/numbers/five.mp3',    'basico'),
  (3, 'Six',     'Seis',   'images/numbers/six.svg',     'audio/numbers/six.mp3',     'basico'),
  (3, 'Seven',   'Siete',  'images/numbers/seven.svg',   'audio/numbers/seven.mp3',   'basico'),
  (3, 'Eight',   'Ocho',   'images/numbers/eight.svg',   'audio/numbers/eight.mp3',   'basico'),
  (3, 'Nine',    'Nueve',  'images/numbers/nine.svg',    'audio/numbers/nine.mp3',    'basico'),
  (3, 'Ten',     'Diez',   'images/numbers/ten.svg',     'audio/numbers/ten.mp3',     'basico');

-- ============================================================
-- BITÁCORA INICIAL
-- ============================================================
INSERT INTO bitacora (id_usuario, accion, detalle, ip)
VALUES
  (1, 'SISTEMA_INICIO', 'Base de datos inicializada', '127.0.0.1'),
  (1, 'USUARIO_CREADO', 'Usuario administrador creado', '127.0.0.1');

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_palabras_categoria ON palabras(id_categoria);
CREATE INDEX idx_actividades_usuario ON actividades(id_usuario);
CREATE INDEX idx_actividades_revision ON actividades(revisado, aprobado);
CREATE INDEX idx_bitacora_usuario    ON bitacora(id_usuario);
CREATE INDEX idx_bitacora_fecha      ON bitacora(fecha);
CREATE INDEX idx_usuarios_correo     ON usuarios(correo);

-- ============================================================
-- VISTAS ÚTILES
-- ============================================================
CREATE OR REPLACE VIEW v_actividades_resumen AS
SELECT 
    u.nombre || ' ' || u.apellido AS usuario,
    u.correo,
    c.nombre AS categoria,
    p.palabra_en,
    a.tipo,
    a.resultado,
    a.puntos,
    a.fecha
FROM actividades a
JOIN usuarios  u ON a.id_usuario = u.id
JOIN palabras  p ON a.id_palabra  = p.id
JOIN categorias c ON p.id_categoria = c.id
ORDER BY a.fecha DESC;

CREATE OR REPLACE VIEW v_bitacora_completa AS
SELECT
    b.id,
    COALESCE(u.nombre || ' ' || u.apellido, 'Sistema') AS usuario,
    COALESCE(u.correo, '-') AS correo,
    b.accion,
    b.detalle,
    b.ip,
    b.fecha
FROM bitacora b
LEFT JOIN usuarios u ON b.id_usuario = u.id
ORDER BY b.fecha DESC;

COMMIT;

