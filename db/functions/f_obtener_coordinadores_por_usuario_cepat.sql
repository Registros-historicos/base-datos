-- FUNCTION: public.f_obtener_coordinadores_por_usuario_cepat(bigint)

CREATE OR REPLACE FUNCTION public.f_obtener_coordinadores_por_usuario_cepat(
    p_id_usuario_sesion bigint)
    RETURNS TABLE(
        id_usuario bigint,
        nombre character varying,
        ape_pat character varying,
        ape_mat character varying,
        url_foto character varying,
        correo character varying,
        pwd character varying,
        telefono character varying,
        tipo_usuario_param bigint,
        estatus_param bigint,
        id_institucion bigint,
        nombre_institucion character varying
    )
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        u_coord.id_usuario,
        u_coord.nombre,
        u_coord.ape_pat,
        u_coord.ape_mat,
        u_coord.url_foto,
        u_coord.correo,
        u_coord.pwd,
        u_coord.telefono,
        u_coord.tipo_usuario_param,
        u_coord.estatus_param,
        i.id_institucion,
        i.nombre AS nombre_institucion
    FROM 
        public.institucion AS i
    JOIN 
        public.cepat AS c ON i.id_cepat = c.id_cepat
    JOIN 
        public.usuario AS u_coord ON i.id_usuario = u_coord.id_usuario
    WHERE 
        c.id_usuario = p_id_usuario_sesion
        AND u_coord.tipo_usuario_param = 36; 
END;
$BODY$;

ALTER FUNCTION public.f_obtener_coordinadores_por_usuario_cepat(bigint) OWNER TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_obtener_coordinadores_por_usuario_cepat(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_obtener_coordinadores_por_usuario_cepat(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_obtener_coordinadores_por_usuario_cepat(bigint) TO ci_app;
GRANT EXECUTE ON FUNCTION public.f_obtener_coordinadores_por_usuario_cepat(bigint) TO ci_owner;