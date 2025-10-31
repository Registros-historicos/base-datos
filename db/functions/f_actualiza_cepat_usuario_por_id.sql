-- FUNCTION: public.f_actualiza_cepat_usuario_por_id(bigint, bigint)
CREATE OR REPLACE FUNCTION public.f_actualiza_cepat_usuario_por_id(
    p_id_cepat bigint,
    p_id_usuario bigint)
    RETURNS TABLE(id_cepat bigint, id_usuario bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
UPDATE cepat c
SET 
    id_usuario = p_id_usuario 
WHERE c.id_cepat = p_id_cepat
RETURNING 
    c.id_cepat,
    c.id_usuario;
END;
$BODY$;

ALTER FUNCTION public.f_actualiza_cepat_usuario_por_id(bigint, bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_actualiza_cepat_usuario_por_id(bigint, bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_actualiza_cepat_usuario_por_id(bigint, bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_actualiza_cepat_usuario_por_id(bigint, bigint) TO ci_app;
GRANT EXECUTE ON FUNCTION public.f_actualiza_cepat_usuario_por_id(bigint, bigint) TO ci_owner;

COMMENT ON FUNCTION public.f_actualiza_cepat_usuario_por_id(bigint, bigint)
    IS 'Actualiza el id_usuario de un cepat y devuelve SÓLO el id_cepat y el id_usuario.';