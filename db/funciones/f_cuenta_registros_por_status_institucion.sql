-- FUNCTION: public.f_cuenta_registros_por_status_institucion(bigint)

-- DROP FUNCTION IF EXISTS public.f_cuenta_registros_por_status_institucion(bigint);

CREATE OR REPLACE FUNCTION public.f_cuenta_registros_por_status_institucion(
    p_id_institucion bigint
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
                 JOIN investigador i          ON i.id_investigador = ri.id_investigador
                 JOIN adscripcion a           ON a.id_investigador = i.id_investigador
        WHERE a.id_institucion = p_id_institucion
        GROUP BY r.estatus_param
        ORDER BY total DESC;
END;
$BODY$;

ALTER FUNCTION public.f_cuenta_registros_por_status_institucion(bigint)
    OWNER TO ci_owner;

GRANT EXECUTE ON FUNCTION public.f_cuenta_registros_por_status_institucion(bigint) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.f_cuenta_registros_por_status_institucion(bigint) TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_cuenta_registros_por_status_institucion(bigint) TO ci_app;

GRANT EXECUTE ON FUNCTION public.f_cuenta_registros_por_status_institucion(bigint) TO ci_owner;

COMMENT ON FUNCTION public.f_cuenta_registros_por_status_institucion(bigint)
    IS 'Conteo DISTINCT de registros por estatus_param de investigador, filtrando por institución específica.';
