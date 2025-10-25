CREATE OR REPLACE FUNCTION public.f_busca_usuario_por_tipo_usuario(
	p_tipo bigint)
    RETURNS TABLE(id_usuario bigint, nombre character varying, ape_pat character varying, ape_mat character varying, url_foto character varying, correo character varying, telefono character varying, tipo_usuario_param bigint, estatus_param bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
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
           u.estatus_param
    FROM usuario u
    WHERE u.tipo_usuario_param = p_tipo;
END;
$BODY$;

ALTER FUNCTION public.f_busca_usuario_por_tipo_usuario(bigint)
    OWNER TO ci_admin; -- O el owner que corresponda

GRANT EXECUTE ON FUNCTION public.f_busca_usuario_por_tipo_usuario(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_busca_usuario_por_tipo_usuario(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_busca_usuario_por_tipo_usuario(bigint) TO ci_app;

COMMENT ON FUNCTION public.f_busca_usuario_por_tipo_usuario(bigint)
    IS 'Busca al usuario por su tipo y devuelve sus datos. NO incluye el hash de la contraseña (pwd).';