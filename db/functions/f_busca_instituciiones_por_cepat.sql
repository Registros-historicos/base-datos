-- FUNCTION: public.f_busca_instituciones_con_cepat()

-- DROP FUNCTION IF EXISTS public.f_busca_instituciones_con_cepat();

CREATE OR REPLACE FUNCTION public.f_busca_instituciones_con_cepat(
	)
    RETURNS SETOF public.institucion
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
SELECT i.*
FROM public.institucion AS i
JOIN public.cepat AS c ON i.id_cepat = c.id_cepat;
END;
$BODY$;

ALTER FUNCTION public.f_busca_instituciones_con_cepat()
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_busca_instituciones_con_cepat() TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.f_busca_instituciones_con_cepat() TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_busca_instituciones_con_cepat() TO ci_app;

GRANT EXECUTE ON FUNCTION public.f_busca_instituciones_con_cepat() TO ci_owner;

COMMENT ON FUNCTION public.f_busca_instituciones_con_cepat()
    IS 'Lista todas las instituciones cuyo id_cepat coincide con un registro en la tabla cepat.';