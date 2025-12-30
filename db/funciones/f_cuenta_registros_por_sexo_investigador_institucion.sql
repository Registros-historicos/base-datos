CREATE OR REPLACE FUNCTION f_cuenta_registros_por_sexo_investigador_institucion(
    p_id_institucion BIGINT
)
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
                 JOIN adscripcion a           ON a.id_investigador = i.id_investigador
        WHERE a.id_institucion = p_id_institucion
        GROUP BY i.sexo_param
        ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_sexo_investigador_institucion(BIGINT)
    IS 'Conteo DISTINCT de registros por sexo_param de investigador, filtrando por institución específica.';