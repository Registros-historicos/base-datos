-- FUNCTION: public.f_cuenta_registros_por_status_cepat(bigint)

-- DROP FUNCTION IF EXISTS public.f_cuenta_registros_por_status_cepat(bigint);

CREATE OR REPLACE FUNCTION public.f_cuenta_registros_por_status_cepat(
    p_id_cepat bigint
)
    RETURNS TABLE(estatus_param bigint, total bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
        SELECT 
            r.estatus_param, 
            COUNT(DISTINCT r.id_registro)::BIGINT AS total
        FROM registro r
            JOIN registro_investigador ri ON ri.id_registro = r.id_registro
            JOIN investigador i           ON i.id_investigador = ri.id_investigador
            JOIN adscripcion a            ON a.id_investigador = i.id_investigador
            JOIN institucion inst         ON inst.id_institucion = a.id_institucion
        WHERE inst.id_cepat = p_id_cepat
        GROUP BY r.estatus_param
        ORDER BY total DESC;
END;
$BODY$;

ALTER FUNCTION public.f_cuenta_registros_por_status_cepat(bigint)
    OWNER TO ci_owner;

GRANT EXECUTE ON FUNCTION public.f_cuenta_registros_por_status_cepat(bigint) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.f_cuenta_registros_por_status_cepat(bigint) TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_cuenta_registros_por_status_cepat(bigint) TO ci_app;

GRANT EXECUTE ON FUNCTION public.f_cuenta_registros_por_status_cepat(bigint) TO ci_owner;

COMMENT ON FUNCTION public.f_cuenta_registros_por_status_cepat(bigint)
    IS 'Conteo DISTINCT de registros por estatus_param de investigador, filtrando por CEPAT específico mediante las relaciones registro → registro_investigador → investigador → adscripcion → institucion.';  
