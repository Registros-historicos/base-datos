-- FUNCTION: public.f_busca_todos_cepat()

DROP FUNCTION IF EXISTS public.f_busca_todos_cepat();

CREATE OR REPLACE FUNCTION public.f_busca_todos_cepat(
	)
    RETURNS TABLE(id_cepat bigint, nombre character varying, id_coordinador bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    STABLE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
SELECT c.id_cepat,
       c.nombre,
       c.id_usuario
FROM cepat c
ORDER BY c.nombre;
END;
$BODY$;

ALTER FUNCTION public.f_busca_todos_cepat()
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_busca_todos_cepat() TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.f_busca_todos_cepat() TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_busca_todos_cepat() TO ci_app;

GRANT EXECUTE ON FUNCTION public.f_busca_todos_cepat() TO ci_owner;

COMMENT ON FUNCTION public.f_busca_todos_cepat()
    IS 'Busca todos los registros de la tabla cepat (incluyendo id_coordinador), ordenados por nombre.'; -- <-- COMENTARIO ACTUALIZADO