-- FUNCTION: public.f_busca_usuario_por_correo_no_login(character varying)

-- DROP FUNCTION IF EXISTS public.f_busca_usuario_por_correo_no_login(character varying);

CREATE OR REPLACE FUNCTION public.f_busca_usuario_por_correo_no_login(
	p_correo character varying)
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
           -- Se omite u.pwd intencionalmente
    FROM usuario u
    WHERE u.correo = p_correo;
END;
$BODY$;

ALTER FUNCTION public.f_busca_usuario_por_correo_no_login(character varying)
    OWNER TO ci_admin; -- O el owner que corresponda

GRANT EXECUTE ON FUNCTION public.f_busca_usuario_por_correo_no_login(character varying) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_busca_usuario_por_correo_no_login(character varying) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_busca_usuario_por_correo_no_login(character varying) TO ci_app;

COMMENT ON FUNCTION public.f_busca_usuario_por_correo_no_login(character varying)
    IS 'Busca al usuario por su correo y devuelve sus datos. NO incluye el hash de la contraseña (pwd).';