CREATE OR REPLACE FUNCTION public.f_buscar_cepat_por_usuario(p_id_usuario bigint)
RETURNS TABLE (
    id_cepat bigint,
    nombre character varying(255),
    id_usuario bigint
)
LANGUAGE plpgsql
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        c.id_cepat,
        c.nombre,
        c.id_usuario
    FROM cepat c
    WHERE c.id_usuario = p_id_usuario;
END;
$BODY$;

ALTER FUNCTION public.f_buscar_cepat_por_usuario(bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_buscar_cepat_por_usuario(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_buscar_cepat_por_usuario(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_buscar_cepat_por_usuario(bigint) TO ci_app;

COMMENT ON FUNCTION public.f_buscar_cepat_por_usuario(bigint)
    IS 'Devuelve la información del CEFAT (o CEFATs) asignados a un id_usuario específico.';