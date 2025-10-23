-- Creación de la función (esta parte estaba bien)
CREATE OR REPLACE FUNCTION public.f_inserta_usuario(
    p_nombre character varying,
    p_ape_pat character varying,
    p_ape_mat character varying,
    p_url_foto character varying,
    p_correo character varying,
    p_pwd character varying,
    p_telefono character varying,
    p_tipo_usuario_param bigint,
    p_estatus_param bigint
)
RETURNS TABLE(
    id_usuario bigint,
    nombre character varying,
    ape_pat character varying,
    ape_mat character varying,
    url_foto character varying,
    correo character varying,
    telefono character varying,
    tipo_usuario_param bigint,
    estatus_param bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    INSERT INTO usuario(
        nombre, ape_pat, ape_mat, url_foto, correo, pwd, telefono, tipo_usuario_param, estatus_param
    )
    VALUES (
        p_nombre, p_ape_pat, p_ape_mat, p_url_foto, p_correo, p_pwd, p_telefono, p_tipo_usuario_param, p_estatus_param
    )
    RETURNING 
        usuario.id_usuario, 
        usuario.nombre, 
        usuario.ape_pat, 
        usuario.ape_mat, 
        usuario.url_foto, 
        usuario.correo, 
        usuario.telefono, 
        usuario.tipo_usuario_param, 
        usuario.estatus_param AS estatus;
END;
$$;


-- CORRECCIÓN: Se especifican los tipos de datos de los parámetros
ALTER FUNCTION public.f_inserta_usuario(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint)
    OWNER TO ci_admin;

-- CORRECCIÓN: Se especifican los tipos de datos en los GRANTs
GRANT EXECUTE ON FUNCTION public.f_inserta_usuario(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_inserta_usuario(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_inserta_usuario(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint) TO ci_app;

-- CORRECCIÓN: Se especifican los tipos de datos y se corrige el texto del comentario
COMMENT ON FUNCTION public.f_inserta_usuario(varchar, varchar, varchar, varchar, varchar, varchar, varchar, bigint, bigint)
    IS 'Inserta un nuevo usuario en la tabla usuario y devuelve el registro completo con el id_usuario generado.';