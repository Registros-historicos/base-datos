-- =====================================================
-- f_cuenta_registros_por_institucion_all
-- Lista TODAS las instituciones con el total de registros asociados
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_institucion_all()
RETURNS TABLE (
    id_institucion BIGINT,
    institucion_nombre VARCHAR,
    total BIGINT
) AS $$
BEGIN
    RETURN QUERY
        SELECT ins.id_institucion,
               ins.nombre AS institucion_nombre,
               COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
        JOIN registro_investigador ri ON ri.id_registro = r.id_registro
        JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
        JOIN institucion ins          ON ins.id_institucion = a.id_institucion
        GROUP BY ins.id_institucion, ins.nombre
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_institucion_all()
    IS 'Devuelve todas las instituciones con su conteo total de registros (sin límite).';


-- =====================================================
-- f_cuenta_registros_por_entidad_all
-- Lista TODAS las entidades federativas con el total de registros
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_entidad_all()
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
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_entidad_all()
    IS 'Devuelve todas las entidades federativas con su conteo total de registros (sin límite).';


-- =====================================================
-- f_cuenta_registros_por_actividad
-- Agrupa por tipo_sector_param (sector económico)
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_actividad()
RETURNS TABLE (
    tipo_sector_param BIGINT,
    sector_nombre VARCHAR,
    total BIGINT
) AS $$
BEGIN
    RETURN QUERY
        SELECT r.tipo_sector_param,
               p.nombre AS sector_nombre,
               COUNT(*)::BIGINT AS total
        FROM registro r
        JOIN parametrizacion p ON p.id_param = r.tipo_sector_param
        GROUP BY r.tipo_sector_param, p.nombre
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_actividad()
    IS 'Devuelve el conteo de registros agrupados por sector económico (tipo_sector_param).';


-- =====================================================
-- f_cuenta_registros_por_institucion_filtrado
-- Permite desglosar instituciones por tipo (Federal / Descentralizado)
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_institucion_filtrado(
    p_tipo_institucion BIGINT  -- id_param de parametrizacion (ej: 122=Descentralizado, 123=Federal)
)
RETURNS TABLE (
    id_institucion BIGINT,
    institucion_nombre VARCHAR,
    total BIGINT
) AS $$
BEGIN
    RETURN QUERY
        SELECT ins.id_institucion,
               ins.nombre AS institucion_nombre,
               COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
        JOIN registro_investigador ri ON ri.id_registro = r.id_registro
        JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
        JOIN institucion ins          ON ins.id_institucion = a.id_institucion
        WHERE ins.tipo_institucion_param = p_tipo_institucion
        GROUP BY ins.id_institucion, ins.nombre
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_institucion_filtrado(BIGINT)
    IS 'Devuelve instituciones filtradas por tipo (ej: Federal o Descentralizado) con total de registros.';


-- =====================================================
-- f_cuenta_registros_por_mes
-- Devuelve el total de registros por mes para un año específico
-- =====================================================
CREATE OR REPLACE FUNCTION f_cuenta_registros_por_mes(
    p_anio INT
)
RETURNS TABLE (
    mes INT,
    total BIGINT
) AS $$
BEGIN
    RETURN QUERY
        SELECT EXTRACT(MONTH FROM r.fec_solicitud)::INT AS mes,
               COUNT(*)::BIGINT AS total
        FROM registro r
        WHERE EXTRACT(YEAR FROM r.fec_solicitud) = p_anio
        GROUP BY EXTRACT(MONTH FROM r.fec_solicitud)
        ORDER BY mes;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_mes(INT)
    IS 'Devuelve el conteo de registros agrupados por mes dentro de un año dado.';