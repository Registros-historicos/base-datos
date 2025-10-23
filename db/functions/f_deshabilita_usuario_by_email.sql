-- FUNCTION: public.f_deshabilita_usuario(character varying, bigint)

-- DROP FUNCTION IF EXISTS public.f_deshabilita_usuario(character varying, bigint);

CREATE OR REPLACE FUNCTION public.f_deshabilita_usuario(
	p_correo character varying,
	p_estatus_inactivo bigint)
    RETURNS TABLE(id_usuario bigint, nombre character varying, ape_pat character varying, ape_mat character varying, url_foto character varying, correo character varying, telefono character varying, tipo_usuario_param bigint, estatus_param bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
        UPDATE usuario u
            SET estatus_param = p_estatus_inactivo
            WHERE u.correo = p_correo
            RETURNING u.id_usuario, u.nombre, u.ape_pat, u.ape_mat, u.url_foto,
                      u.correo, u.telefono, u.tipo_usuario_param, u.estatus_param;
END;
$BODY$;

ALTER FUNCTION public.f_deshabilita_usuario(character varying, bigint)
    OWNER TO ci_admin; -- O el owner que corresponda

GRANT EXECUTE ON FUNCTION public.f_deshabilita_usuario(character varying, bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_deshabilita_usuario(character varying, bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_deshabilita_usuario(character varying, bigint) TO ci_app;

COMMENT ON FUNCTION public.f_deshabilita_usuario(character varying, bigint)
    IS 'Deshabilita a un usuario (por correo) asignando el estatus_param indicado como INACTIVO; retorna el registro actualizado o tabla vacía si no existe.';