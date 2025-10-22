-- FUNCTION: public.f_actualiza_cepat_por_id(bigint, character varying)

-- DROP FUNCTION IF EXISTS public.f_actualiza_cepat_por_id(bigint, character varying);

CREATE OR REPLACE FUNCTION public.f_actualiza_cepat_por_id(
	p_id_cepat bigint,
	p_nombre character varying)
    RETURNS TABLE(id_cepat bigint, nombre character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
UPDATE cepat c
SET nombre = p_nombre
WHERE c.id_cepat = p_id_cepat
RETURNING c.id_cepat,
          c.nombre;
END;
$BODY$;

ALTER FUNCTION public.f_actualiza_cepat_por_id(bigint, character varying)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_actualiza_cepat_por_id(bigint, character varying) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_actualiza_cepat_por_id(bigint, character varying) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_actualiza_cepat_por_id(bigint, character varying) TO ci_app;
GRANT EXECUTE ON FUNCTION public.f_actualiza_cepat_por_id(bigint, character varying) TO ci_owner;

COMMENT ON FUNCTION public.f_actualiza_cepat_por_id(bigint, character varying)
    IS 'Actualiza un registro de cepat por su ID y devuelve el registro actualizado.';