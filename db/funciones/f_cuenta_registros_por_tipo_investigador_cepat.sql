CREATE OR REPLACE FUNCTION f_cuenta_registros_por_tipo_investigador_cepat(
    p_id_cepat BIGINT
)
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
         JOIN adscripcion a           ON a.id_investigador = i.id_investigador
         JOIN institucion inst        ON inst.id_institucion = a.id_institucion
WHERE inst.id_cepat = p_id_cepat
GROUP BY i.tipo_investigador_param
ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION f_cuenta_registros_por_tipo_investigador_cepat(BIGINT)
    IS 'Conteo DISTINCT de registros agrupados por tipo_investigador_param, filtrando por CEPAT específico.';