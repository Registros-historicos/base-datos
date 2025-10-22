-- FUNCTION: public.f_busca_cepat_por_id(bigint)

-- DROP FUNCTION IF EXISTS public.f_busca_cepat_por_id(bigint);

CREATE OR REPLACE FUNCTION public.f_busca_cepat_por_id(
	p_id_cepat bigint)
    RETURNS TABLE(id_cepat bigint, nombre character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    STABLE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
SELECT c.id_cepat,
       c.nombre
FROM cepat c
WHERE c.id_cepat = p_id_cepat;
END;
$BODY$;

ALTER FUNCTION public.f_busca_cepat_por_id(bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_busca_cepat_por_id(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_busca_cepat_por_id(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_busca_cepat_por_id(bigint) TO ci_app;
GRANT EXECUTE ON FUNCTION public.f_busca_cepat_por_id(bigint) TO ci_owner;

COMMENT ON FUNCTION public.f_busca_cepat_por_id(bigint)
    IS 'Busca un registro de cepat por su ID. Si no existe, devuelve tabla vacía.';