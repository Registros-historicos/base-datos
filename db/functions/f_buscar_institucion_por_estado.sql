CREATE OR REPLACE FUNCTION public.f_buscar_institucion_por_estado(
    p_id_entidad_federativa bigint
)
RETURNS TABLE (
    id_institucion bigint,
    nombre_institucion text,
    nombre_entidad_federativa text
)
LANGUAGE plpgsql
COST 100
VOLATILE
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        i.id_institucion,
        i.nombre::text AS nombre_institucion,
        p.nombre::text AS nombre_entidad_federativa
    FROM institucion i
    INNER JOIN parametrizacion p 
        ON i.ent_federativa_param = p.id_param
    WHERE p.id_param = p_id_entidad_federativa;
END;
$BODY$;

ALTER FUNCTION public.f_buscar_institucion_por_estado(bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_buscar_institucion_por_estado(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_buscar_institucion_por_estado(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_buscar_institucion_por_estado(bigint) TO ci_app;

COMMENT ON FUNCTION public.f_buscar_institucion_por_estado(bigint)
    IS 'Devuelve todas las instituciones asociadas a una entidad federativa específica (p_id_entidad_federativa) usando la relación entre institucion y parametrizacion.';
