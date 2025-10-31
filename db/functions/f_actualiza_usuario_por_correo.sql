CREATE OR REPLACE FUNCTION public.f_actualiza_usuario_por_correo(
    p_correo character varying,
    p_nombre character varying,
    p_ape_pat character varying,
    p_ape_mat character varying,
    p_url_foto character varying,
    p_pwd character varying,
    p_telefono character varying,
    p_tipo_usuario_param bigint,
    p_estatus_param bigint
)
RETURNS TABLE( -- El tipo de retorno debe coincidir con las columnas devueltas
    id_usuario bigint,
    nombre character varying,
    ape_pat character varying,
    ape_mat character varying,
    url_foto character varying,
    correo character varying,
    telefono character varying,
    tipo_usuario_param bigint,
    estatus bigint -- La columna devuelta se llamará 'estatus'
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    UPDATE usuario u
    SET 
        nombre = p_nombre,
        ape_pat = p_ape_pat,
        ape_mat = p_ape_mat,
        url_foto = p_url_foto,
        -- Solo actualiza la contraseña si se proporciona una nueva
        pwd = COALESCE(p_pwd, u.pwd),
        telefono = p_telefono,
        tipo_usuario_param = p_tipo_usuario_param,
        estatus_param = p_estatus_param
    WHERE u.correo = p_correo
    RETURNING 
        u.id_usuario,
        u.nombre,
        u.ape_pat,
        u.ape_mat,
        u.url_foto,
        u.correo,
        u.telefono,
        u.tipo_usuario_param,
        u.estatus_param AS estatus; -- <<-- CAMBIOS CLAVE AQUÍ
END;
$$;


-- CORRECCIÓN: Se especifican los tipos de datos de los parámetros
ALTER FUNCTION public.f_actualiza_usuario_por_correo(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint)
    OWNER TO ci_admin;

-- CORRECCIÓN: Se especifican los tipos de datos en los GRANTs
GRANT EXECUTE ON FUNCTION public.f_actualiza_usuario_por_correo(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_actualiza_usuario_por_correo(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_actualiza_usuario_por_correo(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint) TO ci_app;

-- CORRECCIÓN: Se especifican los tipos de datos y se corrige el texto del comentario
COMMENT ON FUNCTION public.f_actualiza_usuario_por_correo(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint)
    IS 'Actualiza un usuario existente en la tabla usuario y devuelve el registro completo actualizado.';