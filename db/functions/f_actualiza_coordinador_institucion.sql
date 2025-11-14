CREATE OR REPLACE FUNCTION public.f_actualiza_coordinador_institucion(
    p_id_institucion integer, 
    p_id_usuario integer
)
RETURNS TABLE( 
    id_institucion bigint,
    nombre character varying,
    ent_federativa_param bigint,
    tipo_institucion_param bigint,
    id_usuario bigint,
    ciudad_param bigint,
    id_cepat bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    UPDATE institucion i
    SET 
        id_usuario = p_id_usuario 
    WHERE i.id_institucion = p_id_institucion
    RETURNING 
        i.id_institucion,
        i.nombre,
        i.ent_federativa_param,
        i.tipo_institucion_param,
        i.id_usuario, 
        i.ciudad_param,
        i.id_cepat;
END;
$$;

ALTER FUNCTION public.f_actualiza_coordinador_institucion(integer, integer)
    OWNER TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_actualiza_coordinador_institucion(integer, integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_actualiza_coordinador_institucion(integer, integer) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_actualiza_coordinador_institucion(integer, integer) TO ci_app;

COMMENT ON FUNCTION public.f_actualiza_coordinador_institucion(integer, integer)
    IS 'Actualiza el ID del coordinador (almacenado en la columna id_usuario) de una institución y devuelve el registro completo actualizado.';