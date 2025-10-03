------------------------------------------------------------------------------------------------------------------------
-- Creación de la base de datos SARHPIT y de los roles CI_APP y CI_ADMIN
------------------------------------------------------------------------------------------------------------------------

CREATE DATABASE "SARHPIT";

CREATE ROLE CI_APP LOGIN PASSWORD '3030_xt_15';
-- Evita que pueda usar el esquema "public"
REVOKE ALL ON SCHEMA public FROM CI_APP;
-- Evita que pueda usar todas las tablas del esquema
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM CI_APP;
-- Evita acceso a secuencias
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM CI_APP;
-- Evita acceso a funciones
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM CI_APP;
GRANT CONNECT ON DATABASE "SARHPIT" TO CI_APP;
GRANT USAGE ON SCHEMA public TO CI_APP;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO CI_APP;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO CI_APP;

CREATE ROLE CI_ADMIN LOGIN PASSWORD '854_pw_159_1_';
GRANT CONNECT ON DATABASE "SARHPIT" TO CI_ADMIN;
GRANT ALL PRIVILEGES ON DATABASE "SARHPIT" TO CI_ADMIN;
GRANT ALL ON SCHEMA public TO CI_ADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO CI_ADMIN;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO CI_ADMIN;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO CI_ADMIN;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO CI_ADMIN;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO CI_ADMIN;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON FUNCTIONS TO CI_ADMIN;


------------------------------------------------------------------------------------------------------------------------
-- Creación de las funciones almacenadas básicas para el sistema SARHPIT
------------------------------------------------------------------------------------------------------------------------

-- ==========================================
-- SARHPIT: Funciones varias (usuarios, registros, conteos y búsquedas)
-- ==========================================


-- =====================================================
-- f_habilita_usuario
-- Habilita a un usuario (por correo) asignando estatus ACTIVO
-- =====================================================
CREATE OR REPLACE FUNCTION f_habilita_usuario(
    p_correo VARCHAR,
    p_estatus_activo BIGINT   -- id en 'parametrizacion' que represente "activo"
)
    RETURNS TABLE (
                      id_usuario BIGINT,
                      nombre VARCHAR,
                      ape_pat VARCHAR,
                      ape_mat VARCHAR,
                      url_foto VARCHAR,
                      correo VARCHAR,
                      telefono VARCHAR,
                      tipo_usuario_param BIGINT,
                      estatus_param BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        UPDATE usuario u
            SET estatus_param = p_estatus_activo
            WHERE u.correo = p_correo
            RETURNING u.id_usuario, u.nombre, u.ape_pat, u.ape_mat, u.url_foto,
                u.correo, u.telefono, u.tipo_usuario_param, u.estatus_param;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_habilita_usuario(VARCHAR, BIGINT)
    IS 'Habilita a un usuario (por correo) asignando el estatus_param indicado como ACTIVO; retorna el registro actualizado o tabla vacía si no existe.';


-- =====================================================
-- f_actualiza_resgistro_por_pk  (sic: nombre solicitado con "resgistro")
-- Actualiza un registro por su PK y devuelve el registro actualizado
-- =====================================================
CREATE OR REPLACE FUNCTION f_actualiza_resgistro_por_pk(
    p_id_registro BIGINT,
    p_no_expediente BIGINT,
    p_titulo VARCHAR,
    p_tipo_ingreso_param BIGINT,
    p_id_usuario BIGINT,
    p_rama_param BIGINT,
    p_fec_expedicion TIMESTAMP,
    p_observaciones VARCHAR,
    p_archivo VARCHAR,
    p_estatus_param BIGINT,
    p_medio_ingreso_param BIGINT,
    p_tipo_registro_param BIGINT,
    p_fec_solicitud TIMESTAMP,
    p_descripcion VARCHAR,
    p_tipo_sector_param BIGINT
)
    RETURNS TABLE (
                      id_registro BIGINT,
                      no_expediente BIGINT,
                      titulo VARCHAR,
                      tipo_ingreso_param BIGINT,
                      id_usuario BIGINT,
                      rama_param BIGINT,
                      fec_expedicion TIMESTAMP,
                      observaciones VARCHAR,
                      archivo VARCHAR,
                      estatus_param BIGINT,
                      medio_ingreso_param BIGINT,
                      tipo_registro_param BIGINT,
                      fec_solicitud TIMESTAMP,
                      descripcion VARCHAR,
                      tipo_sector_param BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        UPDATE registro r
            SET no_expediente       = p_no_expediente,
                titulo              = p_titulo,
                tipo_ingreso_param  = p_tipo_ingreso_param,
                id_usuario          = p_id_usuario,
                rama_param          = p_rama_param,
                fec_expedicion      = p_fec_expedicion,
                observaciones       = p_observaciones,
                archivo             = p_archivo,
                estatus_param       = p_estatus_param,
                medio_ingreso_param = p_medio_ingreso_param,
                tipo_registro_param = p_tipo_registro_param,
                fec_solicitud       = p_fec_solicitud,
                descripcion         = p_descripcion,
                tipo_sector_param   = p_tipo_sector_param
            WHERE r.id_registro = p_id_registro
            RETURNING r.id_registro, r.no_expediente, r.titulo, r.tipo_ingreso_param,
                r.id_usuario, r.rama_param, r.fec_expedicion, r.observaciones,
                r.archivo, r.estatus_param, r.medio_ingreso_param, r.tipo_registro_param,
                r.fec_solicitud, r.descripcion, r.tipo_sector_param;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_actualiza_resgistro_por_pk(
    BIGINT, BIGINT, VARCHAR, BIGINT, BIGINT, BIGINT, TIMESTAMP, VARCHAR, VARCHAR,
    BIGINT, BIGINT, BIGINT, TIMESTAMP, VARCHAR, BIGINT
    ) IS 'Actualiza un registro por PK (id_registro) y retorna el registro actualizado. Devuelve tabla vacía si no existe.';


-- =====================================================
-- f_deshabilita_registro
-- Cambia estatus_param de un registro a "deshabilitado"
-- =====================================================
CREATE OR REPLACE FUNCTION f_deshabilita_registro(
    p_id_registro BIGINT,
    p_estatus_deshabilitado BIGINT
)
    RETURNS TABLE (
                      id_registro BIGINT,
                      estatus_param BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        UPDATE registro r
            SET estatus_param = p_estatus_deshabilitado
            WHERE r.id_registro = p_id_registro
            RETURNING r.id_registro, r.estatus_param;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_deshabilita_registro(BIGINT, BIGINT)
    IS 'Deshabilita un registro (por id_registro) asignando el estatus_param indicado como DESHABILITADO; retorna id_registro y estatus.';


-- =====================================================
-- f_habilita_registro
-- Cambia estatus_param de un registro a "habilitado/activo"
-- =====================================================
CREATE OR REPLACE FUNCTION f_habilita_registro(
    p_id_registro BIGINT,
    p_estatus_activo BIGINT
)
    RETURNS TABLE (
                      id_registro BIGINT,
                      estatus_param BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        UPDATE registro r
            SET estatus_param = p_estatus_activo
            WHERE r.id_registro = p_id_registro
            RETURNING r.id_registro, r.estatus_param;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_habilita_registro(BIGINT, BIGINT)
    IS 'Habilita un registro (por id_registro) asignando el estatus_param indicado como ACTIVO; retorna id_registro y estatus.';


-- =====================================================
-- f_cuenta_resgistros_por_institucion  (sic)
-- Cuenta registros por una institución dada (id_institucion)
-- Join: registro -> registro_investigador -> adscripcion -> institucion
-- Se cuenta DISTINCT por r.id_registro para evitar duplicidades
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_resgistros_por_institucion(
    p_id_institucion BIGINT
)
    RETURNS BIGINT AS $$
DECLARE v_total BIGINT;
BEGIN
    SELECT COUNT(DISTINCT r.id_registro) INTO v_total
    FROM registro r
             JOIN registro_investigador ri ON ri.id_registro = r.id_registro
             JOIN adscripcion a ON a.id_investigador = ri.id_investigador
             JOIN institucion i ON i.id_institucion = a.id_institucion
    WHERE i.id_institucion = p_id_institucion;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_resgistros_por_institucion(BIGINT)
    IS 'Cuenta DISTINCT registros asociados a una institución (vía investigador/adscripción).';


-- =====================================================
-- f_busca_resgistros_por_institucion  (sic)
-- Devuelve los registros asociados a una institución dada, con datos de institución
-- =====================================================
CREATE OR REPLACE FUNCTION f_busca_resgistros_por_institucion(
    p_id_institucion BIGINT
)
    RETURNS TABLE (
                      id_registro BIGINT,
                      no_expediente BIGINT,
                      titulo VARCHAR,
                      tipo_ingreso_param BIGINT,
                      id_usuario BIGINT,
                      rama_param BIGINT,
                      fec_expedicion TIMESTAMP,
                      observaciones VARCHAR,
                      archivo VARCHAR,
                      estatus_param BIGINT,
                      medio_ingreso_param BIGINT,
                      tipo_registro_param BIGINT,
                      fec_solicitud TIMESTAMP,
                      descripcion VARCHAR,
                      tipo_sector_param BIGINT,
                      id_institucion BIGINT,
                      institucion_nombre VARCHAR
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT DISTINCT r.id_registro, r.no_expediente, r.titulo, r.tipo_ingreso_param,
                        r.id_usuario, r.rama_param, r.fec_expedicion, r.observaciones, r.archivo,
                        r.estatus_param, r.medio_ingreso_param, r.tipo_registro_param, r.fec_solicitud,
                        r.descripcion, r.tipo_sector_param,
                        i.id_institucion, i.nombre
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
                 JOIN institucion i            ON i.id_institucion = a.id_institucion
        WHERE i.id_institucion = p_id_institucion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_busca_resgistros_por_institucion(BIGINT)
    IS 'Devuelve registros asociados a una institución (JOIN registro -> registro_investigador -> adscripcion -> institucion).';


-- =====================================================
-- f_busca_registros_por_tipo
-- Filtra por tipo_registro_param (asunción común de "tipo")
-- =====================================================
CREATE OR REPLACE FUNCTION f_busca_registros_por_tipo(
    p_tipo_registro_param BIGINT,   -- 44 = IMPI, 45 = INDAUTOR
    p_limit INT,
    p_offset INT,
    p_sort_column VARCHAR DEFAULT 'fec_solicitud',
    p_sort_order  VARCHAR DEFAULT 'DESC'
)
RETURNS TABLE (
    id_registro BIGINT,
    no_expediente BIGINT,
    titulo VARCHAR,
    tipo_ingreso_param BIGINT,
    id_usuario BIGINT,
    rama_param BIGINT,
    fec_expedicion TIMESTAMP,
    observaciones VARCHAR,
    archivo VARCHAR,
    estatus_param BIGINT,
    medio_ingreso_param BIGINT,
    tipo_registro_param BIGINT,
    fec_solicitud TIMESTAMP,
    descripcion VARCHAR,
    tipo_sector_param BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_allowed_cols CONSTANT text[] := ARRAY[
        'id_registro','no_expediente','titulo','tipo_ingreso_param',
        'id_usuario','rama_param','fec_expedicion','estatus_param',
        'medio_ingreso_param','tipo_registro_param','fec_solicitud',
        'tipo_sector_param'
    ];

    v_sort_col text;
    v_sort_dir text;
    v_limit    int;
    v_offset   int;
    v_sql      text;
BEGIN
    v_sort_dir := CASE lower(coalesce(p_sort_order,'desc'))
                    WHEN 'asc'  THEN 'ASC'
                    WHEN 'desc' THEN 'DESC'
                    ELSE 'DESC'
                  END;

    v_sort_col := CASE
        WHEN p_sort_column = ANY (v_allowed_cols) THEN p_sort_column
        ELSE 'fec_solicitud'
    END;

    v_limit  := GREATEST(0, LEAST(coalesce(p_limit, 50), 1000));
    v_offset := GREATEST(0, coalesce(p_offset, 0));

    v_sql := format(
        'SELECT id_registro, no_expediente, titulo, tipo_ingreso_param,
                id_usuario, rama_param, fec_expedicion, observaciones,
                archivo, estatus_param, medio_ingreso_param, tipo_registro_param,
                fec_solicitud, descripcion, tipo_sector_param
         FROM registro
         WHERE tipo_registro_param = $1
         ORDER BY %I %s
         LIMIT $2 OFFSET $3',
        v_sort_col, v_sort_dir
    );

    RETURN QUERY EXECUTE v_sql
        USING p_tipo_registro_param, v_limit, v_offset;
END;
$$;

COMMENT ON FUNCTION f_busca_registros_por_tipo(BIGINT, INT, INT, VARCHAR, VARCHAR)
IS 'Busca registros por tipo_registro_param con orden y paginación validados.';

-- =====================================================
-- f_cuenta_registros_por_tipo
-- Cuenta registros para un tipo_registro_param específico
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_tipo(
    p_tipo_registro_param BIGINT
)
RETURNS BIGINT AS $$
DECLARE v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM registro
    WHERE tipo_registro_param = p_tipo_registro_param;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION f_cuenta_registros_por_tipo(BIGINT)
    IS 'Cuenta registros por un valor de tipo_registro_param.';


CREATE OR REPLACE FUNCTION f_busca_registros_por_texto(
    p_tipo_registro_param BIGINT,   -- 44 = IMPI, 45 = INDAUTOR
    p_search VARCHAR,               -- texto de búsqueda
    p_limit INT,
    p_offset INT,
    p_sort_column VARCHAR DEFAULT 'fec_solicitud',
    p_sort_order  VARCHAR DEFAULT 'DESC'
)
RETURNS TABLE (
    id_registro BIGINT,
    no_expediente BIGINT,
    titulo VARCHAR,
    tipo_ingreso_param BIGINT,
    id_usuario BIGINT,
    rama_param BIGINT,
    fec_expedicion TIMESTAMP,
    observaciones VARCHAR,
    archivo VARCHAR,
    estatus_param BIGINT,
    medio_ingreso_param BIGINT,
    tipo_registro_param BIGINT,
    fec_solicitud TIMESTAMP,
    descripcion VARCHAR,
    tipo_sector_param BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Whitelist de columnas permitidas para ORDER BY
    v_allowed_cols CONSTANT text[] := ARRAY[
        'id_registro','no_expediente','titulo','tipo_ingreso_param',
        'id_usuario','rama_param','fec_expedicion','estatus_param',
        'medio_ingreso_param','tipo_registro_param','fec_solicitud',
        'tipo_sector_param'
    ];

    v_sort_col text;
    v_sort_dir text;
    v_limit    int;
    v_offset   int;
    v_sql      text;
    v_pattern  text;
BEGIN
    -- Normalizar dirección de orden
    v_sort_dir := CASE lower(coalesce(p_sort_order,'desc'))
                    WHEN 'asc'  THEN 'ASC'
                    WHEN 'desc' THEN 'DESC'
                    ELSE 'DESC'
                  END;

    -- Validar columna a ordenar
    v_sort_col := CASE
        WHEN p_sort_column = ANY (v_allowed_cols) THEN p_sort_column
        ELSE 'fec_solicitud'
    END;

    -- Guardrails de paginación
    v_limit  := GREATEST(0, LEAST(coalesce(p_limit, 50), 1000));
    v_offset := GREATEST(0, coalesce(p_offset, 0));

    -- Construir patrón seguro para ILIKE (contiene).  Nota: '%%' si p_search es NULL/''.
    v_pattern := '%' || coalesce(p_search, '') || '%';

    -- Solo el ORDER BY es dinámico y usa %I (identificador) con nombre validado
    v_sql := format(
        'SELECT id_registro, no_expediente, titulo, tipo_ingreso_param,
                id_usuario, rama_param, fec_expedicion, observaciones,
                archivo, estatus_param, medio_ingreso_param, tipo_registro_param,
                fec_solicitud, descripcion, tipo_sector_param
         FROM registro
         WHERE tipo_registro_param = $1
           AND (
               titulo ILIKE $2
               OR descripcion ILIKE $2
               OR CAST(no_expediente AS TEXT) ILIKE $2
           )
         ORDER BY %I %s
         LIMIT $3 OFFSET $4',
        v_sort_col, v_sort_dir
    );

    RETURN QUERY EXECUTE v_sql
        USING p_tipo_registro_param, v_pattern, v_limit, v_offset;
END;
$$;

COMMENT ON FUNCTION f_busca_registros_por_texto(BIGINT, VARCHAR, INT, INT, VARCHAR, VARCHAR)
IS 'Busca registros por tipo y texto (ILIKE) con ORDER BY validado y parámetros pasados con USING.';


CREATE OR REPLACE FUNCTION f_contar_registros_por_texto(
    p_tipo_registro_param BIGINT,
    p_search VARCHAR
)
RETURNS BIGINT AS $$
DECLARE v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM registro r
    WHERE r.tipo_registro_param = p_tipo_registro_param
      AND (
          r.titulo ILIKE '%'||p_search||'%' 
          OR r.descripcion ILIKE '%'||p_search||'%'
          OR CAST(r.no_expediente AS TEXT) ILIKE '%'||p_search||'%'
      );

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;


COMMENT ON FUNCTION f_contar_registros_por_texto(BIGINT, VARCHAR)
    IS 'Cuenta registros filtrando por tipo_registro_param y texto en titulo, descripcion o no_expediente.';


-- =====================================================
-- f_cuenta_registros_por_tipo_registro
-- Devuelve el total de registros agrupados por tipo_registro_param
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_tipo_registro()
    RETURNS TABLE (
                      tipo_registro_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT r.tipo_registro_param, COUNT(*)::BIGINT AS total
        FROM registro r
        GROUP BY r.tipo_registro_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_tipo_registro()
    IS 'Conteo de registros por cada tipo_registro_param.';


-- =====================================================
-- f_cuenta_registros_por_tipo_investigador
-- Total por tipo_investigador_param (JOIN a investigador)
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_tipo_investigador()
    RETURNS TABLE (
                      tipo_investigador_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT i.tipo_investigador_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN investigador i          ON i.id_investigador = ri.id_investigador
        GROUP BY i.tipo_investigador_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_tipo_investigador()
    IS 'Conteo DISTINCT de registros agrupados por tipo_investigador_param.';


-- =====================================================
-- f_busca_registros_por_rama
-- Filtra por rama_param
-- =====================================================
CREATE OR REPLACE FUNCTION f_busca_registros_por_rama(
    p_rama_param BIGINT
)
    RETURNS TABLE (
                      id_registro BIGINT,
                      no_expediente BIGINT,
                      titulo VARCHAR,
                      tipo_ingreso_param BIGINT,
                      id_usuario BIGINT,
                      rama_param BIGINT,
                      fec_expedicion TIMESTAMP,
                      observaciones VARCHAR,
                      archivo VARCHAR,
                      estatus_param BIGINT,
                      medio_ingreso_param BIGINT,
                      tipo_registro_param BIGINT,
                      fec_solicitud TIMESTAMP,
                      descripcion VARCHAR,
                      tipo_sector_param BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT r.id_registro, r.no_expediente, r.titulo, r.tipo_ingreso_param,
               r.id_usuario, r.rama_param, r.fec_expedicion, r.observaciones,
               r.archivo, r.estatus_param, r.medio_ingreso_param, r.tipo_registro_param,
               r.fec_solicitud, r.descripcion, r.tipo_sector_param
        FROM registro r
        WHERE r.rama_param = p_rama_param;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_busca_registros_por_rama(BIGINT)
    IS 'Devuelve registros filtrando por rama_param.';


-- =====================================================
-- f_cuenta_registros_por_tipo_institucion
-- Cuenta DISTINCT registros agrupados por tipo_institucion_param
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_tipo_institucion()
    RETURNS TABLE (
                      tipo_institucion_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT ins.tipo_institucion_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
                 JOIN institucion ins          ON ins.id_institucion = a.id_institucion
        GROUP BY ins.tipo_institucion_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_tipo_institucion()
    IS 'Conteo DISTINCT de registros agrupados por tipo_institucion_param (vía institución de las adscripciones).';


-- =====================================================
-- f_cuenta_registros_por_institucion_top10
-- Top 10 instituciones por cantidad de registros
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_institucion_top10()
    RETURNS TABLE (
                      id_institucion BIGINT,
                      institucion_nombre VARCHAR,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT ins.id_institucion, ins.nombre, COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
                 JOIN institucion ins          ON ins.id_institucion = a.id_institucion
        GROUP BY ins.id_institucion, ins.nombre
        ORDER BY total DESC
        LIMIT 10;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_institucion_top10()
    IS 'Top 10 instituciones con más registros (cuenta DISTINCT por registro).';


-- =====================================================
-- f_cuenta_registros_por_entidad_top10
-- Top 10 por entidad federativa (parametrizacion.nombre)
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_entidad_top10()
    RETURNS TABLE (
                      ent_federativa_param BIGINT,
                      entidad_nombre VARCHAR,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT ins.ent_federativa_param,
               p.nombre AS entidad_nombre,
               COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
                 JOIN institucion ins          ON ins.id_institucion = a.id_institucion
                 JOIN parametrizacion p        ON p.id_param = ins.ent_federativa_param
        GROUP BY ins.ent_federativa_param, p.nombre
        ORDER BY total DESC
        LIMIT 10;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_entidad_top10()
    IS 'Top 10 de conteo DISTINCT de registros por entidad federativa (usa parametrizacion.nombre).';


-- =====================================================
-- f_cuenta_registros_por_rango_de_fecha_de_solicitud
-- Cuenta registros con fec_solicitud dentro de [p_inicio, p_fin]
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_rango_de_fecha_de_solicitud(
    p_inicio TIMESTAMP,
    p_fin TIMESTAMP
)
    RETURNS BIGINT AS $$
DECLARE v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM registro r
    WHERE r.fec_solicitud >= p_inicio
      AND r.fec_solicitud <= p_fin;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_rango_de_fecha_de_solicitud(TIMESTAMP, TIMESTAMP)
    IS 'Cuenta registros cuya fec_solicitud está dentro del rango [inicio, fin] (inclusive).';


-- =====================================================
-- f_cuenta_registros_por_sectores
-- Conteo agrupado por tipo_sector_param
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_sectores()
    RETURNS TABLE (
                      tipo_sector_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT r.tipo_sector_param, COUNT(*)::BIGINT AS total
        FROM registro r
        GROUP BY r.tipo_sector_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_sectores()
    IS 'Conteo de registros agrupados por tipo_sector_param.';


-- =====================================================
-- f_cuenta_registros_por_cuerpo_academico
-- Conteo DISTINCT por cuerpo_academico_param (JOIN vía adscripcion)
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_cuerpo_academico()
    RETURNS TABLE (
                      cuerpo_academico_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT a.cuerpo_academico_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
        GROUP BY a.cuerpo_academico_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_cuerpo_academico()
    IS 'Conteo DISTINCT de registros agrupados por cuerpo_academico_param (desde adscripcion).';


-- =====================================================
-- f_cuenta_registros_por_status
-- Conteo por estatus_param de registro
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_status()
    RETURNS TABLE (
                      estatus_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT r.estatus_param, COUNT(*)::BIGINT AS total
        FROM registro r
        GROUP BY r.estatus_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_status()
    IS 'Conteo de registros agrupados por estatus_param.';


-- =====================================================
-- f_cuenta_registros_por_departamento
-- DISTINCT por departamento_param (adscripcion)
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_departamento()
    RETURNS TABLE (
                      departamento_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT a.departamento_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
        GROUP BY a.departamento_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_departamento()
    IS 'Conteo DISTINCT de registros agrupados por departamento_param (desde adscripcion).';


-- =====================================================
-- f_cuenta_registros_por_programa_educativo
-- DISTINCT por programa_educativo_param (adscripcion)
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_programa_educativo()
    RETURNS TABLE (
                      programa_educativo_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT a.programa_educativo_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
        GROUP BY a.programa_educativo_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_programa_educativo()
    IS 'Conteo DISTINCT de registros agrupados por programa_educativo_param (desde adscripcion).';


-- =====================================================
-- f_cuenta_registros_por_investigador
-- Conteo por investigador (id_investigador)
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_investigador()
    RETURNS TABLE (
                      id_investigador BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT ri.id_investigador, COUNT(DISTINCT ri.id_registro)::BIGINT AS total
        FROM registro_investigador ri
        GROUP BY ri.id_investigador
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_investigador()
    IS 'Conteo DISTINCT de registros por investigador (usa tabla puente registro_investigador).';


-- =====================================================
-- f_cuenta_registros_por_sexo_investigador
-- Conteo por sexo_param del investigador
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_sexo_investigador()
    RETURNS TABLE (
                      sexo_param BIGINT,
                      total BIGINT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT i.sexo_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
                 JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                 JOIN investigador i          ON i.id_investigador = ri.id_investigador
        GROUP BY i.sexo_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_sexo_investigador()
    IS 'Conteo DISTINCT de registros por sexo_param de investigador.';


-- =====================================================
-- f_busca_tema_por_nombre
-- Búsqueda por nombre_tema con coincidencia parcial (ILIKE)
-- =====================================================
CREATE OR REPLACE FUNCTION f_busca_tema_por_nombre(
    p_busqueda VARCHAR
)
    RETURNS TABLE (
                      id_tema BIGINT,
                      id_subtema BIGINT,
                      nombre_tema VARCHAR
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT t.id_tema, t.id_subtema, t.nombre_tema
        FROM tema t
        WHERE t.nombre_tema ILIKE '%' || p_busqueda || '%';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_busca_tema_por_nombre(VARCHAR)
    IS 'Busca temas por coincidencia parcial (ILIKE) en nombre_tema.';


-- =====================================================
-- f_busca_pram_por_nombre  (sic)
-- Busca en parametrizacion por nombre con coincidencia parcial
-- =====================================================
CREATE OR REPLACE FUNCTION f_busca_pram_por_nombre(
    p_busqueda VARCHAR
)
    RETURNS TABLE (
                      id_param BIGINT,
                      id_tema BIGINT,
                      nombre VARCHAR
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT p.id_param, p.id_tema, p.nombre
        FROM parametrizacion p
        WHERE p.nombre ILIKE '%' || p_busqueda || '%';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_busca_pram_por_nombre(VARCHAR)
    IS 'Busca parámetros por nombre (ILIKE) en la tabla parametrizacion.';


-- =====================================================
-- f_busca_pram_por_tema  (sic)
-- Devuelve parámetros por id_tema
-- =====================================================
CREATE OR REPLACE FUNCTION f_busca_pram_por_tema(
    p_id_tema BIGINT
)
    RETURNS TABLE (
                      id_param BIGINT,
                      id_tema BIGINT,
                      nombre VARCHAR
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT p.id_param, p.id_tema, p.nombre
        FROM parametrizacion p
        WHERE p.id_tema = p_id_tema;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_busca_pram_por_tema(BIGINT)
    IS 'Devuelve los registros de parametrizacion asociados a un id_tema dado.';


-- =====================================================
-- f_busca_subtemas_por_tema
-- Dado un id_tema (padre), devuelve sus subtemas (hijos)
-- Nota: en el esquema, tema.id_subtema referencia a tema.id_tema (padre)
-- Por tanto, los "hijos" son las filas donde id_subtema = p_id_tema
-- =====================================================
CREATE OR REPLACE FUNCTION f_busca_subtemas_por_tema(
    p_id_tema BIGINT
)
    RETURNS TABLE (
                      id_tema BIGINT,
                      id_subtema BIGINT,
                      nombre_tema VARCHAR
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT t.id_tema, t.id_subtema, t.nombre_tema
        FROM tema t
        WHERE t.id_subtema = p_id_tema;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_busca_subtemas_por_tema(BIGINT)
    IS 'Devuelve subtemas (hijos) cuyo id_subtema apunta al id_tema padre indicado.';


-- =====================================================
-- f_busca_tipo_usuario_por_pk
-- Devuelve el registro de parametrizacion dado id_param (tipo de usuario)
-- =====================================================
CREATE OR REPLACE FUNCTION f_busca_tipo_usuario_por_pk(
    p_id_param BIGINT
)
    RETURNS TABLE (
                      id_param BIGINT,
                      id_tema BIGINT,
                      nombre VARCHAR
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT p.id_param, p.id_tema, p.nombre
        FROM parametrizacion p
        WHERE p.id_param = p_id_param;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_busca_tipo_usuario_por_pk(BIGINT)
    IS 'Devuelve el registro de parametrizacion cuyo id_param = p_id_param (útil para tipo_usuario_param).';


------------------------------------------------------------------------------------------------------------------------
-- Script de creación de la base de datos extraído con pg_dump para contener datos de catálogos
------------------------------------------------------------------------------------------------------------------------
--
-- CI_OWNERQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-09-08 11:44:14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 247 (class 1255 OID 17893)
-- Name: f_actualiza_usuario_por_correo(character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint, bigint); Type: FUNCTION; Schema: public; Owner: CI_ADMIN
--

CREATE FUNCTION public.f_actualiza_usuario_por_correo(p_correo character varying, p_nombre character varying, p_ape_pat character varying, p_ape_mat character varying, p_url_foto character varying, p_pwd character varying, p_telefono character varying, p_tipo_usuario_param bigint, p_estatus_param bigint) RETURNS TABLE(id_usuario bigint, nombre character varying, ape_pat character varying, ape_mat character varying, url_foto character varying, correo character varying, telefono character varying, tipo_usuario_param bigint, estatus_param bigint, pwd character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
UPDATE usuario u
SET nombre = p_nombre,
    ape_pat = p_ape_pat,
    ape_mat = p_ape_mat,
    url_foto = p_url_foto,
    pwd = p_pwd,
    telefono = p_telefono,
    tipo_usuario_param = p_tipo_usuario_param,
    estatus_param = p_estatus_param
WHERE u.correo = p_correo
    RETURNING u.id_usuario,
              u.nombre,
              u.ape_pat,
              u.ape_mat,
              u.url_foto,
              u.correo,
              u.telefono,
              u.tipo_usuario_param,
              u.estatus_param,
              u.pwd;
END;
$$;


ALTER FUNCTION public.f_actualiza_usuario_por_correo(p_correo character varying, p_nombre character varying, p_ape_pat character varying, p_ape_mat character varying, p_url_foto character varying, p_pwd character varying, p_telefono character varying, p_tipo_usuario_param bigint, p_estatus_param bigint) OWNER TO CI_ADMIN;

--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 247
-- Name: FUNCTION f_actualiza_usuario_por_correo(p_correo character varying, p_nombre character varying, p_ape_pat character varying, p_ape_mat character varying, p_url_foto character varying, p_pwd character varying, p_telefono character varying, p_tipo_usuario_param bigint, p_estatus_param bigint); Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON FUNCTION public.f_actualiza_usuario_por_correo(p_correo character varying, p_nombre character varying, p_ape_pat character varying, p_ape_mat character varying, p_url_foto character varying, p_pwd character varying, p_telefono character varying, p_tipo_usuario_param bigint, p_estatus_param bigint) IS 'Actualiza los datos de un usuario identificado por su correo y devuelve el registro actualizado. Si no existe, devuelve tabla vacía.';


--
-- TOC entry 249 (class 1255 OID 17895)
-- Name: f_busca_registro_por_numero_de_expediente(bigint); Type: FUNCTION; Schema: public; Owner: CI_ADMIN
--

CREATE FUNCTION public.f_busca_registro_por_numero_de_expediente(p_no_expediente bigint) RETURNS TABLE(id_registro bigint, no_expediente bigint, titulo character varying, tipo_ingreso_param bigint, id_usuario bigint, rama_param bigint, fec_expedicion timestamp without time zone, observaciones character varying, archivo character varying, estatus_param bigint, medio_ingreso_param bigint, tipo_registro_param bigint, fec_solicitud timestamp without time zone, descripcion character varying, tipo_sector_param bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT r.id_registro, r.no_expediente, r.titulo, r.tipo_ingreso_param,
       r.id_usuario, r.rama_param, r.fec_expedicion, r.observaciones,
       r.archivo, r.estatus_param, r.medio_ingreso_param, r.tipo_registro_param,
       r.fec_solicitud, r.descripcion, r.tipo_sector_param
FROM registro r
WHERE r.no_expediente = p_no_expediente;
END;
$$;


ALTER FUNCTION public.f_busca_registro_por_numero_de_expediente(p_no_expediente bigint) OWNER TO CI_ADMIN;

--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 249
-- Name: FUNCTION f_busca_registro_por_numero_de_expediente(p_no_expediente bigint); Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON FUNCTION public.f_busca_registro_por_numero_de_expediente(p_no_expediente bigint) IS 'Busca un registro por su número de expediente. Devuelve los datos del registro.';


--
-- TOC entry 248 (class 1255 OID 17894)
-- Name: f_busca_registro_por_pk(bigint); Type: FUNCTION; Schema: public; Owner: CI_ADMIN
--

CREATE FUNCTION public.f_busca_registro_por_pk(p_id_registro bigint) RETURNS TABLE(id_registro bigint, no_expediente bigint, titulo character varying, tipo_ingreso_param bigint, id_usuario bigint, rama_param bigint, fec_expedicion timestamp without time zone, observaciones character varying, archivo character varying, estatus_param bigint, medio_ingreso_param bigint, tipo_registro_param bigint, fec_solicitud timestamp without time zone, descripcion character varying, tipo_sector_param bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT r.id_registro, r.no_expediente, r.titulo, r.tipo_ingreso_param,
       r.id_usuario, r.rama_param, r.fec_expedicion, r.observaciones,
       r.archivo, r.estatus_param, r.medio_ingreso_param, r.tipo_registro_param,
       r.fec_solicitud, r.descripcion, r.tipo_sector_param
FROM registro r
WHERE r.id_registro = p_id_registro;
END;
$$;


ALTER FUNCTION public.f_busca_registro_por_pk(p_id_registro bigint) OWNER TO CI_ADMIN;

--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 248
-- Name: FUNCTION f_busca_registro_por_pk(p_id_registro bigint); Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON FUNCTION public.f_busca_registro_por_pk(p_id_registro bigint) IS 'Busca un registro por su PK (id_registro). Devuelve los datos del registro.';


--
-- TOC entry 234 (class 1255 OID 17891)
-- Name: f_busca_usuario_por_correo(character varying); Type: FUNCTION; Schema: public; Owner: CI_ADMIN
--

CREATE FUNCTION public.f_busca_usuario_por_correo(p_correo character varying) RETURNS TABLE(id_usuario bigint, nombre character varying, ape_pat character varying, ape_mat character varying, url_foto character varying, correo character varying, telefono character varying, tipo_usuario_param bigint, estatus_param bigint, pwd character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT u.id_usuario,
       u.nombre,
       u.ape_pat,
       u.ape_mat,
       u.url_foto,
       u.correo,
       u.telefono,
       u.tipo_usuario_param,
       u.estatus_param,
       u.pwd
FROM usuario u
WHERE u.correo = p_correo;
END;
$$;


ALTER FUNCTION public.f_busca_usuario_por_correo(p_correo character varying) OWNER TO CI_ADMIN;

--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 234
-- Name: FUNCTION f_busca_usuario_por_correo(p_correo character varying); Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON FUNCTION public.f_busca_usuario_por_correo(p_correo character varying) IS 'Función para login: busca al usuario por su correo y devuelve todos los datos, incluido el hash de la contraseña (pwd).';


--
-- TOC entry 250 (class 1255 OID 17896)
-- Name: f_inserta_nuevo_registro(bigint, character varying, bigint, bigint, bigint, timestamp without time zone, character varying, character varying, bigint, bigint, bigint, timestamp without time zone, character varying, bigint); Type: FUNCTION; Schema: public; Owner: CI_ADMIN
--

CREATE FUNCTION public.f_inserta_nuevo_registro(p_no_expediente bigint, p_titulo character varying, p_tipo_ingreso_param bigint, p_id_usuario bigint, p_rama_param bigint, p_fec_expedicion timestamp without time zone, p_observaciones character varying, p_archivo character varying, p_estatus_param bigint, p_medio_ingreso_param bigint, p_tipo_registro_param bigint, p_fec_solicitud timestamp without time zone, p_descripcion character varying, p_tipo_sector_param bigint) RETURNS TABLE(id_registro bigint, no_expediente bigint, titulo character varying, tipo_ingreso_param bigint, id_usuario bigint, rama_param bigint, fec_expedicion timestamp without time zone, observaciones character varying, archivo character varying, estatus_param bigint, medio_ingreso_param bigint, tipo_registro_param bigint, fec_solicitud timestamp without time zone, descripcion character varying, tipo_sector_param bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
    INSERT INTO registro(
        no_expediente, titulo, tipo_ingreso_param, id_usuario, rama_param,
        fec_expedicion, observaciones, archivo, estatus_param,
        medio_ingreso_param, tipo_registro_param, fec_solicitud,
        descripcion, tipo_sector_param
    )
    VALUES (
        p_no_expediente, p_titulo, p_tipo_ingreso_param, p_id_usuario, p_rama_param,
        p_fec_expedicion, p_observaciones, p_archivo, p_estatus_param,
        p_medio_ingreso_param, p_tipo_registro_param, p_fec_solicitud,
        p_descripcion, p_tipo_sector_param
    )
    RETURNING id_registro, no_expediente, titulo, tipo_ingreso_param, id_usuario,
              rama_param, fec_expedicion, observaciones, archivo, estatus_param,
              medio_ingreso_param, tipo_registro_param, fec_solicitud,
              descripcion, tipo_sector_param;
END;
$$;


ALTER FUNCTION public.f_inserta_nuevo_registro(p_no_expediente bigint, p_titulo character varying, p_tipo_ingreso_param bigint, p_id_usuario bigint, p_rama_param bigint, p_fec_expedicion timestamp without time zone, p_observaciones character varying, p_archivo character varying, p_estatus_param bigint, p_medio_ingreso_param bigint, p_tipo_registro_param bigint, p_fec_solicitud timestamp without time zone, p_descripcion character varying, p_tipo_sector_param bigint) OWNER TO CI_ADMIN;

--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 250
-- Name: FUNCTION f_inserta_nuevo_registro(p_no_expediente bigint, p_titulo character varying, p_tipo_ingreso_param bigint, p_id_usuario bigint, p_rama_param bigint, p_fec_expedicion timestamp without time zone, p_observaciones character varying, p_archivo character varying, p_estatus_param bigint, p_medio_ingreso_param bigint, p_tipo_registro_param bigint, p_fec_solicitud timestamp without time zone, p_descripcion character varying, p_tipo_sector_param bigint); Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON FUNCTION public.f_inserta_nuevo_registro(p_no_expediente bigint, p_titulo character varying, p_tipo_ingreso_param bigint, p_id_usuario bigint, p_rama_param bigint, p_fec_expedicion timestamp without time zone, p_observaciones character varying, p_archivo character varying, p_estatus_param bigint, p_medio_ingreso_param bigint, p_tipo_registro_param bigint, p_fec_solicitud timestamp without time zone, p_descripcion character varying, p_tipo_sector_param bigint) IS 'Inserta un nuevo registro en la tabla registro y devuelve el registro completo recién insertado con su id_registro.';


--
-- TOC entry 235 (class 1255 OID 17892)
-- Name: f_inserta_usuario(character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint, bigint); Type: FUNCTION; Schema: public; Owner: CI_ADMIN
--

CREATE FUNCTION public.f_inserta_usuario(p_nombre character varying, p_ape_pat character varying, p_ape_mat character varying, p_url_foto character varying, p_correo character varying, p_pwd character varying, p_telefono character varying, p_tipo_usuario_param bigint, p_estatus_param bigint) RETURNS TABLE(id_usuario bigint, nombre character varying, ape_pat character varying, ape_mat character varying, url_foto character varying, correo character varying, telefono character varying, tipo_usuario_param bigint, estatus_param bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
    INSERT INTO usuario(
        nombre, ape_pat, ape_mat, url_foto, correo, pwd, telefono, tipo_usuario_param, estatus_param
    )
    VALUES (
        p_nombre, p_ape_pat, p_ape_mat, p_url_foto, p_correo, p_pwd, p_telefono, p_tipo_usuario_param, p_estatus_param
    )
    RETURNING id_usuario, nombre, ape_pat, ape_mat, url_foto, correo, telefono, tipo_usuario_param, estatus_param;
END;
$$;


ALTER FUNCTION public.f_inserta_usuario(p_nombre character varying, p_ape_pat character varying, p_ape_mat character varying, p_url_foto character varying, p_correo character varying, p_pwd character varying, p_telefono character varying, p_tipo_usuario_param bigint, p_estatus_param bigint) OWNER TO CI_ADMIN;

--
-- TOC entry 5017 (class 0 OID 0)
-- Dependencies: 235
-- Name: FUNCTION f_inserta_usuario(p_nombre character varying, p_ape_pat character varying, p_ape_mat character varying, p_url_foto character varying, p_correo character varying, p_pwd character varying, p_telefono character varying, p_tipo_usuario_param bigint, p_estatus_param bigint); Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON FUNCTION public.f_inserta_usuario(p_nombre character varying, p_ape_pat character varying, p_ape_mat character varying, p_url_foto character varying, p_correo character varying, p_pwd character varying, p_telefono character varying, p_tipo_usuario_param bigint, p_estatus_param bigint) IS 'Inserta un nuevo usuario en la tabla usuario y devuelve el registro completo con el id_usuario generado.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 17703)
-- Name: adscripcion; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.adscripcion (
                                    id_adscripcion bigint NOT NULL,
                                    departamento_param bigint NOT NULL,
                                    programa_educativo_param bigint NOT NULL,
                                    cuerpo_academico_param bigint NOT NULL,
                                    fec_ini timestamp without time zone NOT NULL,
                                    fec_fin timestamp without time zone,
                                    id_institucion bigint NOT NULL,
                                    id_investigador bigint NOT NULL
);


ALTER TABLE public.adscripcion OWNER TO CI_ADMIN;

--
-- TOC entry 217 (class 1259 OID 17702)
-- Name: adscripcion_id_adscripcion_seq; Type: SEQUENCE; Schema: public; Owner: CI_ADMIN
--

CREATE SEQUENCE public.adscripcion_id_adscripcion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adscripcion_id_adscripcion_seq OWNER TO CI_ADMIN;

--
-- TOC entry 5018 (class 0 OID 0)
-- Dependencies: 217
-- Name: adscripcion_id_adscripcion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CI_ADMIN
--

ALTER SEQUENCE public.adscripcion_id_adscripcion_seq OWNED BY public.adscripcion.id_adscripcion;


--
-- TOC entry 220 (class 1259 OID 17710)
-- Name: cepat; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.cepat (
                              id_cepat bigint NOT NULL,
                              nombre character varying(255) NOT NULL
);


ALTER TABLE public.cepat OWNER TO CI_ADMIN;

--
-- TOC entry 5019 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE cepat; Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON TABLE public.cepat IS 'Solo el catálogo de CEPATS';


--
-- TOC entry 219 (class 1259 OID 17709)
-- Name: cepat_id_cepat_seq; Type: SEQUENCE; Schema: public; Owner: CI_ADMIN
--

CREATE SEQUENCE public.cepat_id_cepat_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cepat_id_cepat_seq OWNER TO CI_ADMIN;

--
-- TOC entry 5020 (class 0 OID 0)
-- Dependencies: 219
-- Name: cepat_id_cepat_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CI_ADMIN
--

ALTER SEQUENCE public.cepat_id_cepat_seq OWNED BY public.cepat.id_cepat;


--
-- TOC entry 222 (class 1259 OID 17717)
-- Name: institucion; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.institucion (
                                    id_institucion bigint NOT NULL,
                                    nombre character varying(255) NOT NULL,
                                    ent_federativa_param bigint NOT NULL,
                                    tipo_institucion_param bigint NOT NULL,
                                    id_cepat bigint NOT NULL,
                                    ciudad_param bigint NOT NULL
);


ALTER TABLE public.institucion OWNER TO CI_ADMIN;

--
-- TOC entry 5021 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE institucion; Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON TABLE public.institucion IS 'Solo el catálogo de instituciones';


--
-- TOC entry 221 (class 1259 OID 17716)
-- Name: institucion_id_institucion_seq; Type: SEQUENCE; Schema: public; Owner: CI_ADMIN
--

CREATE SEQUENCE public.institucion_id_institucion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.institucion_id_institucion_seq OWNER TO CI_ADMIN;

--
-- TOC entry 5022 (class 0 OID 0)
-- Dependencies: 221
-- Name: institucion_id_institucion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CI_ADMIN
--

ALTER SEQUENCE public.institucion_id_institucion_seq OWNED BY public.institucion.id_institucion;


--
-- TOC entry 224 (class 1259 OID 17724)
-- Name: investigador; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.investigador (
                                     id_investigador bigint NOT NULL,
                                     curp character varying(100) NOT NULL,
                                     nombre character varying(100) NOT NULL,
                                     ape_pat character varying(100) NOT NULL,
                                     ape_mat character varying(100),
                                     sexo_param bigint NOT NULL,
                                     tipo_investigador_param bigint NOT NULL
);


ALTER TABLE public.investigador OWNER TO CI_ADMIN;

--
-- TOC entry 5023 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN investigador.curp; Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON COLUMN public.investigador.curp IS 'CURP o clave de identidad para otros países';


--
-- TOC entry 223 (class 1259 OID 17723)
-- Name: investigador_id_investigador_seq; Type: SEQUENCE; Schema: public; Owner: CI_ADMIN
--

CREATE SEQUENCE public.investigador_id_investigador_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.investigador_id_investigador_seq OWNER TO CI_ADMIN;

--
-- TOC entry 5024 (class 0 OID 0)
-- Dependencies: 223
-- Name: investigador_id_investigador_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CI_ADMIN
--

ALTER SEQUENCE public.investigador_id_investigador_seq OWNED BY public.investigador.id_investigador;


--
-- TOC entry 226 (class 1259 OID 17733)
-- Name: parametrizacion; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.parametrizacion (
                                        id_param bigint NOT NULL,
                                        id_tema bigint NOT NULL,
                                        nombre character varying(255) NOT NULL
);


ALTER TABLE public.parametrizacion OWNER TO CI_ADMIN;

--
-- TOC entry 225 (class 1259 OID 17732)
-- Name: parametrizacion_id_param_seq; Type: SEQUENCE; Schema: public; Owner: CI_ADMIN
--

CREATE SEQUENCE public.parametrizacion_id_param_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parametrizacion_id_param_seq OWNER TO CI_ADMIN;

--
-- TOC entry 5025 (class 0 OID 0)
-- Dependencies: 225
-- Name: parametrizacion_id_param_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CI_ADMIN
--

ALTER SEQUENCE public.parametrizacion_id_param_seq OWNED BY public.parametrizacion.id_param;


--
-- TOC entry 228 (class 1259 OID 17740)
-- Name: registro; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.registro (
                                 id_registro bigint NOT NULL,
                                 no_expediente bigint NOT NULL,
                                 titulo character varying(255) NOT NULL,
                                 tipo_ingreso_param bigint NOT NULL,
                                 id_usuario bigint NOT NULL,
                                 rama_param bigint NOT NULL,
                                 fec_expedicion timestamp without time zone,
                                 observaciones character varying(255),
                                 archivo character varying(255) NOT NULL,
                                 estatus_param bigint NOT NULL,
                                 medio_ingreso_param bigint NOT NULL,
                                 tipo_registro_param bigint NOT NULL,
                                 fec_solicitud timestamp without time zone NOT NULL,
                                 descripcion character varying(255),
                                 tipo_sector_param bigint NOT NULL
);


ALTER TABLE public.registro OWNER TO CI_ADMIN;

--
-- TOC entry 5026 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN registro.tipo_ingreso_param; Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON COLUMN public.registro.tipo_ingreso_param IS 'Tipo, puede ser IMPI o INDAUTOR';


--
-- TOC entry 227 (class 1259 OID 17739)
-- Name: registro_id_registro_seq; Type: SEQUENCE; Schema: public; Owner: CI_ADMIN
--

CREATE SEQUENCE public.registro_id_registro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.registro_id_registro_seq OWNER TO CI_ADMIN;

--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 227
-- Name: registro_id_registro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CI_ADMIN
--

ALTER SEQUENCE public.registro_id_registro_seq OWNED BY public.registro.id_registro;


--
-- TOC entry 229 (class 1259 OID 17748)
-- Name: registro_investigador; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.registro_investigador (
                                              id_registro bigint NOT NULL,
                                              id_investigador bigint NOT NULL
);


ALTER TABLE public.registro_investigador OWNER TO CI_ADMIN;

--
-- TOC entry 231 (class 1259 OID 17754)
-- Name: tema; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.tema (
                             id_tema bigint NOT NULL,
                             id_subtema bigint,
                             nombre_tema character varying(255) NOT NULL
);


ALTER TABLE public.tema OWNER TO CI_ADMIN;

--
-- TOC entry 230 (class 1259 OID 17753)
-- Name: tema_id_tema_seq; Type: SEQUENCE; Schema: public; Owner: CI_ADMIN
--

CREATE SEQUENCE public.tema_id_tema_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tema_id_tema_seq OWNER TO CI_ADMIN;

--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 230
-- Name: tema_id_tema_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CI_ADMIN
--

ALTER SEQUENCE public.tema_id_tema_seq OWNED BY public.tema.id_tema;


--
-- TOC entry 233 (class 1259 OID 17761)
-- Name: usuario; Type: TABLE; Schema: public; Owner: CI_ADMIN
--

CREATE TABLE public.usuario (
                                id_usuario bigint NOT NULL,
                                nombre character varying(100) NOT NULL,
                                ape_pat character varying(100) NOT NULL,
                                ape_mat character varying(100),
                                url_foto character varying(255),
                                correo character varying(150) NOT NULL,
                                pwd character varying(255) NOT NULL,
                                telefono character varying(15) NOT NULL,
                                tipo_usuario_param bigint NOT NULL,
                                estatus_param bigint NOT NULL
);


ALTER TABLE public.usuario OWNER TO CI_ADMIN;

--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN usuario.tipo_usuario_param; Type: COMMENT; Schema: public; Owner: CI_ADMIN
--

COMMENT ON COLUMN public.usuario.tipo_usuario_param IS 'Coordinador, CEPAT o administrador';


--
-- TOC entry 232 (class 1259 OID 17760)
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: CI_ADMIN
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_usuario_seq OWNER TO CI_ADMIN;

--
-- TOC entry 5030 (class 0 OID 0)
-- Dependencies: 232
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CI_ADMIN
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- TOC entry 4790 (class 2604 OID 17706)
-- Name: adscripcion id_adscripcion; Type: DEFAULT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.adscripcion ALTER COLUMN id_adscripcion SET DEFAULT nextval('public.adscripcion_id_adscripcion_seq'::regclass);


--
-- TOC entry 4791 (class 2604 OID 17713)
-- Name: cepat id_cepat; Type: DEFAULT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.cepat ALTER COLUMN id_cepat SET DEFAULT nextval('public.cepat_id_cepat_seq'::regclass);


--
-- TOC entry 4792 (class 2604 OID 17720)
-- Name: institucion id_institucion; Type: DEFAULT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.institucion ALTER COLUMN id_institucion SET DEFAULT nextval('public.institucion_id_institucion_seq'::regclass);


--
-- TOC entry 4793 (class 2604 OID 17727)
-- Name: investigador id_investigador; Type: DEFAULT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.investigador ALTER COLUMN id_investigador SET DEFAULT nextval('public.investigador_id_investigador_seq'::regclass);


--
-- TOC entry 4794 (class 2604 OID 17736)
-- Name: parametrizacion id_param; Type: DEFAULT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.parametrizacion ALTER COLUMN id_param SET DEFAULT nextval('public.parametrizacion_id_param_seq'::regclass);


--
-- TOC entry 4795 (class 2604 OID 17743)
-- Name: registro id_registro; Type: DEFAULT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro ALTER COLUMN id_registro SET DEFAULT nextval('public.registro_id_registro_seq'::regclass);


--
-- TOC entry 4796 (class 2604 OID 17757)
-- Name: tema id_tema; Type: DEFAULT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.tema ALTER COLUMN id_tema SET DEFAULT nextval('public.tema_id_tema_seq'::regclass);


--
-- TOC entry 4797 (class 2604 OID 17764)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- TOC entry 4990 (class 0 OID 17703)
-- Dependencies: 218
-- Data for Name: adscripcion; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--



--
-- TOC entry 4992 (class 0 OID 17710)
-- Dependencies: 220
-- Data for Name: cepat; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--



--
-- TOC entry 4994 (class 0 OID 17717)
-- Dependencies: 222
-- Data for Name: institucion; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--



--
-- TOC entry 4996 (class 0 OID 17724)
-- Dependencies: 224
-- Data for Name: investigador; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--



--
-- TOC entry 4998 (class 0 OID 17733)
-- Dependencies: 226
-- Data for Name: parametrizacion; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--

INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (1, 1, 'Masculino');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (2, 1, 'Femenino');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (3, 2, 'Primario');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (4, 2, 'Secundario');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (5, 2, 'Terciario');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (6, 2, 'Cuaternario');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (7, 2, 'Quinario');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (8, 3, 'Audiovisual');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (9, 3, 'Copilacion de datos (Base de datos)');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (10, 3, 'Dibujo');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (11, 3, 'ISBN');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (12, 3, 'ISSN');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (13, 3, 'Literaria');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (14, 3, 'LITERARIA (ARTE DIGITAL POR ANALOGÍA)');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (15, 3, 'Programa de computación');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (16, 3, 'Programa de computación (App por Analogía)');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (17, 3, 'Reserva de Derechos');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (18, 4, 'Indautor');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (19, 4, 'ISBN');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (20, 4, 'INDAINDAUTOR - CENTRO NACIONAL DE ISSN UTOR');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (21, 4, 'VENTANILLA');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (22, 4, 'INDAUTOR - CENTRO NACIONAL DE ISSN');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (23, 4, 'Indarelin');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (24, 5, 'Habilitado');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (25, 5, 'Deshabilitado');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (26, 7, 'Confirmada');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (27, 7, 'Pendiente');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (28, 7, 'Con Observaciones');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (29, 7, 'Rechazada');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (30, 7, 'Finalizada');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (31, 7, 'Cancelada');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (32, 7, 'En pausa');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (33, 7, 'En espera de validación');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (34, 7, 'Notificada al Tecnológico');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (35, 6, 'Administrador');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (36, 6, 'Coordinador');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (37, 6, 'CEPAT');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (38, 8, 'Indautor');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (39, 8, 'ISBN');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (40, 8, 'INDAINDAUTOR - CENTRO NACIONAL DE ISSN UTOR');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (41, 8, 'VENTANILLA');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (42, 8, 'INDAUTOR - CENTRO NACIONAL DE ISSN');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (43, 8, 'Indarelin');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (44, 9, 'IMPI');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (45, 9, 'INDAUTOR');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (46, 10, 'Docente');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (47, 10, 'Administrativo');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (48, 10, 'Alumno');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (49, 11, 'Eléctrica/Electrónica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (50, 11, 'Sistemas Computacionales');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (51, 11, 'Mecánica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (52, 11, 'Gestión Empresarial');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (53, 11, 'Química');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (54, 11, 'Industrial');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (55, 11, 'Económico-Administrativo');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (56, 11, 'Varias');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (57, 12, 'Ingeniería en Semiconductores');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (58, 12, 'Ingeniería Informática');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (59, 12, 'Ingeniería en Sistemas Computacionales');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (60, 12, 'Ingeniería en Ciencia de Datos');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (61, 12, 'Ingeniería Eléctrica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (62, 12, 'Ingeniería Mecánica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (63, 12, 'Ingeniería en Gestión Empresarial');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (64, 12, 'Ingeniería Electrónica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (65, 12, 'Ingeniería Química');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (66, 12, 'Ingeniería Industrial');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (67, 12, 'Ingeniería Industrial en línea');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (68, 12, 'Especialidad en Semiconductores');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (69, 12, 'Doctorado en Ciencias de la Ingeniería Química');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (70, 12, 'Doctorado en Ciencias de la Ingeniería');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (71, 12, 'Maestría en Economía Social y Solidaria');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (72, 12, 'Maestría en Ingeniería Electrónica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (73, 12, 'Maestría en Ingeniería Industrial');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (74, 12, 'Maestría en Ciencias de la Ingeniería Química');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (75, 12, 'Maestría en Ingeniería Administrativa');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (76, 12, 'Maestría en Sistemas Computacionales');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (77, 13, 'CA de Semiconductores');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (78, 13, 'CA de Informática y Computación');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (79, 13, 'CA de Sistemas Computacionales');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (80, 13, 'CA de Ciencia de Datos');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (81, 13, 'CA de Energía y Electrónica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (82, 13, 'CA de Mecánica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (83, 13, 'CA de Gestión Empresarial');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (84, 13, 'CA de Electrónica');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (85, 13, 'CA de Ingeniería Química');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (86, 13, 'CA de Ingeniería Industrial');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (87, 13, 'CA Multidisciplinarios');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (88, 13, 'CA de Economía Social');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (89, 13, 'CA de Ingeniería Administrativa');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (90, 14, 'Aguascalientes');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (91, 14, 'Baja California');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (92, 14, 'Baja California Sur');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (93, 14, 'Campeche');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (94, 14, 'Chiapas');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (95, 14, 'Chihuahua');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (96, 14, 'Coahuila');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (97, 14, 'Colima');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (98, 14, 'Ciudad de México');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (99, 14, 'Durango');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (100, 14, 'Guanajuato');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (101, 14, 'Guerrero');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (102, 14, 'Hidalgo');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (103, 14, 'Jalisco');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (104, 14, 'México');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (105, 14, 'Michoacán');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (106, 14, 'Morelos');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (107, 14, 'Nayarit');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (108, 14, 'Nuevo León');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (109, 14, 'Oaxaca');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (110, 14, 'Puebla');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (111, 14, 'Querétaro');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (112, 14, 'Quintana Roo');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (113, 14, 'San Luis Potosí');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (114, 14, 'Sinaloa');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (115, 14, 'Sonora');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (116, 14, 'Tabasco');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (117, 14, 'Tamaulipas');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (118, 14, 'Tlaxcala');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (119, 14, 'Veracruz');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (120, 14, 'Yucatán');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (121, 14, 'Zacatecas');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (122, 15, 'INSTITUTO TECNOLOGICO DESCENTRALIZADO');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (123, 15, 'INSTITUTO TECNOLOGICO FEDERAL');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (124, 16, 'Acapulco');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (125, 16, 'Chihuahua');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (126, 16, 'Matehuala');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (127, 16, 'Tehuacán');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (128, 16, 'Orizaba');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (129, 16, 'Mérida');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (130, 16, 'Tláhuac');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (131, 16, 'Tuxtla Gutiérrez');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (132, 16, 'Tepic');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (133, 16, 'Durango');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (134, 16, 'Agua Prieta');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (135, 16, 'Aguascalientes');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (136, 16, 'Altamirano');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (137, 16, 'Apizaco');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (138, 16, 'Cancún');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (139, 16, 'Celaya');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (140, 16, 'Chetumal');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (141, 16, 'Chontalpa');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (142, 16, 'Conkal');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (143, 16, 'Ensenada');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (144, 16, 'Jesús Carranza');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (145, 16, 'La Laguna');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (146, 16, 'Lerma');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (147, 16, 'Linares');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (148, 16, 'Matamoros');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (149, 16, 'Mexicali');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (150, 16, 'Milpa Alta');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (151, 16, 'Minatitlán');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (152, 16, 'Nogales');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (153, 16, 'Nuevo León');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (154, 16, 'Pachuca');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (155, 16, 'Pánuco');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (156, 16, 'Pochutla');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (157, 16, 'Puebla');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (158, 16, 'Región Carbonífera');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (159, 16, 'Roque');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (160, 16, 'Saltillo');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (161, 16, 'San Juan del Río');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (162, 16, 'Tijuana');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (163, 16, 'Tlajomulco');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (164, 16, 'Tlalnepantla');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (165, 16, 'Villahermosa');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (166, 16, 'Xalapa');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (167, 16, 'Zacatecas');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (168, 16, 'Zacatepec');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (169, 16, 'Zitácuaro');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (170, 16, 'Valle de Morelia');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (171, 16, 'Valle de Oaxaca');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (172, 16, 'Valle del Yaqui');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (173, 16, 'El Llano Aguascalientes');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (174, 16, 'Costa Grande');
INSERT INTO public.parametrizacion (id_param, id_tema, nombre) VALUES (175, 16, 'Costa Chica');


--
-- TOC entry 5000 (class 0 OID 17740)
-- Dependencies: 228
-- Data for Name: registro; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--



--
-- TOC entry 5001 (class 0 OID 17748)
-- Dependencies: 229
-- Data for Name: registro_investigador; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--



--
-- TOC entry 5003 (class 0 OID 17754)
-- Dependencies: 231
-- Data for Name: tema; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--

INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (1, NULL, 'Sexo');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (2, NULL, 'Sector');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (3, NULL, 'Rama');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (4, NULL, 'Método de ingreso');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (5, NULL, 'Estatus de usuario');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (6, NULL, 'Tipo de usuario');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (7, NULL, 'Estatus del registro');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (8, NULL, 'Tipo de ingreso');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (9, NULL, 'Tipo de registro');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (10, NULL, 'Tipo de investigador');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (11, NULL, 'Departamento');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (12, NULL, 'Programa educativo');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (13, NULL, 'Cuerpo académico');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (14, NULL, 'Entidad federativa');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (15, NULL, 'Tipo de institución');
INSERT INTO public.tema (id_tema, id_subtema, nombre_tema) VALUES (16, NULL, 'Ciudad');


--
-- TOC entry 5005 (class 0 OID 17761)
-- Dependencies: 233
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: CI_ADMIN
--



--
-- TOC entry 5031 (class 0 OID 0)
-- Dependencies: 217
-- Name: adscripcion_id_adscripcion_seq; Type: SEQUENCE SET; Schema: public; Owner: CI_ADMIN
--

SELECT pg_catalog.setval('public.adscripcion_id_adscripcion_seq', 1, false);


--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 219
-- Name: cepat_id_cepat_seq; Type: SEQUENCE SET; Schema: public; Owner: CI_ADMIN
--

SELECT pg_catalog.setval('public.cepat_id_cepat_seq', 1, false);


--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 221
-- Name: institucion_id_institucion_seq; Type: SEQUENCE SET; Schema: public; Owner: CI_ADMIN
--

SELECT pg_catalog.setval('public.institucion_id_institucion_seq', 1, false);


--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 223
-- Name: investigador_id_investigador_seq; Type: SEQUENCE SET; Schema: public; Owner: CI_ADMIN
--

SELECT pg_catalog.setval('public.investigador_id_investigador_seq', 1, false);


--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 225
-- Name: parametrizacion_id_param_seq; Type: SEQUENCE SET; Schema: public; Owner: CI_ADMIN
--

SELECT pg_catalog.setval('public.parametrizacion_id_param_seq', 175, true);


--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 227
-- Name: registro_id_registro_seq; Type: SEQUENCE SET; Schema: public; Owner: CI_ADMIN
--

SELECT pg_catalog.setval('public.registro_id_registro_seq', 1, false);


--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 230
-- Name: tema_id_tema_seq; Type: SEQUENCE SET; Schema: public; Owner: CI_ADMIN
--

SELECT pg_catalog.setval('public.tema_id_tema_seq', 16, true);


--
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 232
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: CI_ADMIN
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 1, false);


--
-- TOC entry 4799 (class 2606 OID 17708)
-- Name: adscripcion adscripcion_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.adscripcion
    ADD CONSTRAINT adscripcion_pkey PRIMARY KEY (id_adscripcion);


--
-- TOC entry 4801 (class 2606 OID 17715)
-- Name: cepat cepat_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.cepat
    ADD CONSTRAINT cepat_pkey PRIMARY KEY (id_cepat);


--
-- TOC entry 4803 (class 2606 OID 17722)
-- Name: institucion institucion_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT institucion_pkey PRIMARY KEY (id_institucion);


--
-- TOC entry 4805 (class 2606 OID 17731)
-- Name: investigador investigador_curp_key; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.investigador
    ADD CONSTRAINT investigador_curp_key UNIQUE (curp);


--
-- TOC entry 4807 (class 2606 OID 17729)
-- Name: investigador investigador_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.investigador
    ADD CONSTRAINT investigador_pkey PRIMARY KEY (id_investigador);


--
-- TOC entry 4809 (class 2606 OID 17738)
-- Name: parametrizacion parametrizacion_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.parametrizacion
    ADD CONSTRAINT parametrizacion_pkey PRIMARY KEY (id_param);


--
-- TOC entry 4813 (class 2606 OID 17752)
-- Name: registro_investigador registro_investigador_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro_investigador
    ADD CONSTRAINT registro_investigador_pkey PRIMARY KEY (id_registro, id_investigador);


--
-- TOC entry 4811 (class 2606 OID 17747)
-- Name: registro registro_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT registro_pkey PRIMARY KEY (id_registro);


--
-- TOC entry 4815 (class 2606 OID 17759)
-- Name: tema tema_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.tema
    ADD CONSTRAINT tema_pkey PRIMARY KEY (id_tema);


--
-- TOC entry 4817 (class 2606 OID 17770)
-- Name: usuario usuario_correo_key; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_correo_key UNIQUE (correo);


--
-- TOC entry 4819 (class 2606 OID 17768)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4820 (class 2606 OID 17846)
-- Name: adscripcion fkadscripcio252572; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.adscripcion
    ADD CONSTRAINT fkadscripcio252572 FOREIGN KEY (programa_educativo_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4821 (class 2606 OID 17811)
-- Name: adscripcion fkadscripcio649219; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.adscripcion
    ADD CONSTRAINT fkadscripcio649219 FOREIGN KEY (id_institucion) REFERENCES public.institucion(id_institucion);


--
-- TOC entry 4822 (class 2606 OID 17841)
-- Name: adscripcion fkadscripcio653311; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.adscripcion
    ADD CONSTRAINT fkadscripcio653311 FOREIGN KEY (departamento_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4823 (class 2606 OID 17826)
-- Name: adscripcion fkadscripcio765852; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.adscripcion
    ADD CONSTRAINT fkadscripcio765852 FOREIGN KEY (id_investigador) REFERENCES public.investigador(id_investigador);


--
-- TOC entry 4824 (class 2606 OID 17851)
-- Name: adscripcion fkadscripcio97512; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.adscripcion
    ADD CONSTRAINT fkadscripcio97512 FOREIGN KEY (cuerpo_academico_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4825 (class 2606 OID 17821)
-- Name: institucion fkinstitucio178984; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT fkinstitucio178984 FOREIGN KEY (tipo_institucion_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4826 (class 2606 OID 17881)
-- Name: institucion fkinstitucio44332; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT fkinstitucio44332 FOREIGN KEY (ciudad_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4827 (class 2606 OID 17831)
-- Name: institucion fkinstitucio691777; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT fkinstitucio691777 FOREIGN KEY (id_cepat) REFERENCES public.cepat(id_cepat);


--
-- TOC entry 4828 (class 2606 OID 17816)
-- Name: institucion fkinstitucio741751; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT fkinstitucio741751 FOREIGN KEY (ent_federativa_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4829 (class 2606 OID 17796)
-- Name: investigador fkinvestigad509173; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.investigador
    ADD CONSTRAINT fkinvestigad509173 FOREIGN KEY (sexo_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4830 (class 2606 OID 17791)
-- Name: investigador fkinvestigad683473; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.investigador
    ADD CONSTRAINT fkinvestigad683473 FOREIGN KEY (tipo_investigador_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4831 (class 2606 OID 17801)
-- Name: parametrizacion fkparametriz944633; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.parametrizacion
    ADD CONSTRAINT fkparametriz944633 FOREIGN KEY (id_tema) REFERENCES public.tema(id_tema);


--
-- TOC entry 4832 (class 2606 OID 17861)
-- Name: registro fkregistro135382; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT fkregistro135382 FOREIGN KEY (estatus_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4833 (class 2606 OID 17871)
-- Name: registro fkregistro585904; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT fkregistro585904 FOREIGN KEY (tipo_registro_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4834 (class 2606 OID 17866)
-- Name: registro fkregistro609398; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT fkregistro609398 FOREIGN KEY (medio_ingreso_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4835 (class 2606 OID 17786)
-- Name: registro fkregistro612655; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT fkregistro612655 FOREIGN KEY (tipo_ingreso_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4836 (class 2606 OID 17856)
-- Name: registro fkregistro741910; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT fkregistro741910 FOREIGN KEY (rama_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4837 (class 2606 OID 17876)
-- Name: registro fkregistro829779; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT fkregistro829779 FOREIGN KEY (tipo_sector_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4838 (class 2606 OID 17771)
-- Name: registro fkregistro932257; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro
    ADD CONSTRAINT fkregistro932257 FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4839 (class 2606 OID 17776)
-- Name: registro_investigador fkregistro_i41513; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro_investigador
    ADD CONSTRAINT fkregistro_i41513 FOREIGN KEY (id_registro) REFERENCES public.registro(id_registro);


--
-- TOC entry 4840 (class 2606 OID 17781)
-- Name: registro_investigador fkregistro_i779937; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.registro_investigador
    ADD CONSTRAINT fkregistro_i779937 FOREIGN KEY (id_investigador) REFERENCES public.investigador(id_investigador);


--
-- TOC entry 4841 (class 2606 OID 17806)
-- Name: tema fktema308392; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.tema
    ADD CONSTRAINT fktema308392 FOREIGN KEY (id_subtema) REFERENCES public.tema(id_tema);


--
-- TOC entry 4842 (class 2606 OID 17886)
-- Name: usuario fkusuario503998; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fkusuario503998 FOREIGN KEY (estatus_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 4843 (class 2606 OID 17836)
-- Name: usuario fkusuario759090; Type: FK CONSTRAINT; Schema: public; Owner: CI_ADMIN
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fkusuario759090 FOREIGN KEY (tipo_usuario_param) REFERENCES public.parametrizacion(id_param);


--
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO CI_APP;
GRANT ALL ON SCHEMA public TO CI_ADMIN;


--
-- TOC entry 2090 (class 826 OID 17701)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: CI_OWNER
--

ALTER DEFAULT PRIVILEGES FOR ROLE CI_OWNER IN SCHEMA public GRANT ALL ON SEQUENCES TO CI_ADMIN;


--
-- TOC entry 2091 (class 826 OID 17698)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: CI_OWNER
--

ALTER DEFAULT PRIVILEGES FOR ROLE CI_OWNER IN SCHEMA public GRANT ALL ON FUNCTIONS TO CI_APP;
ALTER DEFAULT PRIVILEGES FOR ROLE CI_OWNER IN SCHEMA public GRANT ALL ON FUNCTIONS TO CI_ADMIN;


--
-- TOC entry 2089 (class 826 OID 17700)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: CI_OWNER
--

ALTER DEFAULT PRIVILEGES FOR ROLE CI_OWNER IN SCHEMA public GRANT ALL ON TABLES TO CI_ADMIN;


-- Completed on 2025-09-08 11:44:14

--
-- CI_OWNERQL database dump complete
--