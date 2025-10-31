CREATE OR REPLACE FUNCTION public.f_elimina_usuario_by_id(
    p_id_usuario bigint
)
RETURNS void
LANGUAGE plpgsql
COST 100
VOLATILE
AS $BODY$
BEGIN
    DELETE FROM usuario
    WHERE id_usuario = p_id_usuario;
END;
$BODY$;

ALTER FUNCTION public.f_elimina_usuario_by_id(bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_elimina_usuario_by_id(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_elimina_usuario_by_id(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_elimina_usuario_by_id(bigint) TO ci_app;

COMMENT ON FUNCTION public.f_elimina_usuario_by_id(bigint)
    IS 'Elimina un usuario de la tabla usuario por su id_usuario sin retornar ningún valor.';
