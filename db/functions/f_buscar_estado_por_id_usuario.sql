CREATE OR REPLACE FUNCTION public.f_buscar_estados_por_usuario(p_id_usuario bigint)
RETURNS TABLE (
    id_entidad_federativa bigint,
    nombre_entidad character varying(255)
)
LANGUAGE plpgsql
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        p.id_param AS id_entidad_federativa,
        p.nombre AS nombre_entidad
    FROM
        usuario AS u
    JOIN
        cepat AS c ON u.id_usuario = c.id_usuario
    JOIN
        institucion AS i ON c.id_cepat = i.id_cepat
    JOIN
        parametrizacion AS p ON i.ent_federativa_param = p.id_param
    WHERE
        u.id_usuario = p_id_usuario;
END;
$BODY$;

ALTER FUNCTION public.f_buscar_estados_por_usuario(bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_buscar_estados_por_usuario(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_buscar_estados_por_usuario(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_buscar_estados_por_usuario(bigint) TO ci_app;

COMMENT ON FUNCTION public.f_buscar_estados_por_usuario(bigint)
    IS 'Devuelve los estados (id_param y nombre) asociados a un usuario específico a través de sus CEPATs e instituciones.';