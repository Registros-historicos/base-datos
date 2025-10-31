CREATE OR REPLACE FUNCTION public.f_buscar_estados()
RETURNS TABLE (
    id_entidad_federativa bigint,
    nombre_entidad character varying(255)
)
LANGUAGE plpgsql
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_param AS id_entidad_federativa,
        p.nombre AS nombre_entidad
    FROM parametrizacion p
    WHERE p.id_tema = 14
    ORDER BY p.nombre;
END;
$BODY$;

ALTER FUNCTION public.f_buscar_estados()
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_buscar_estados() TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_buscar_estados() TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_buscar_estados() TO ci_app;

COMMENT ON FUNCTION public.f_buscar_estados()
    IS 'Devuelve todas las entidades federativas (id_param y nombre) de la tabla parametrizacion donde id_tema = 14.';
