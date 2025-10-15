CREATE OR REPLACE FUNCTION f_cuenta_registros_por_institucion_all()
RETURNS TABLE (
    id_institucion BIGINT,
    institucion_nombre TEXT,
    tipo_institucion_nombre TEXT,
    total BIGINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ins.id_institucion,
        ins.nombre::TEXT AS institucion_nombre,
        p.nombre::TEXT AS tipo_institucion_nombre,
        COUNT(DISTINCT r.id_registro)::BIGINT AS total
    FROM institucion ins
    INNER JOIN parametrizacion p
        ON ins.tipo_institucion_param = p.id_param
    LEFT JOIN adscripcion a
        ON ins.id_institucion = a.id_institucion
    LEFT JOIN registro_investigador ri
        ON a.id_investigador = ri.id_investigador
    LEFT JOIN registro r
        ON r.id_registro = ri.id_registro
    GROUP BY ins.id_institucion, ins.nombre, p.nombre
    ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;
