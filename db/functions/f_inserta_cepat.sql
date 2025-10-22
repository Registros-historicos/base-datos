-- FUNCTION: public.f_inserta_cepat(character varying)

-- DROP FUNCTION IF EXISTS public.f_inserta_cepat(character varying);

CREATE OR REPLACE FUNCTION public.f_inserta_cepat(
	p_nombre character varying)
    RETURNS TABLE(id_cepat bigint, nombre character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
INSERT INTO cepat(nombre)
VALUES (p_nombre)
RETURNING cepat.id_cepat,
          cepat.nombre;
END;
$BODY$;

ALTER FUNCTION public.f_inserta_cepat(character varying)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_inserta_cepat(character varying) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_inserta_cepat(character varying) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_inserta_cepat(character varying) TO ci_app;
GRANT EXECUTE ON FUNCTION public.f_inserta_cepat(character varying) TO ci_owner;

COMMENT ON FUNCTION public.f_inserta_cepat(character varying)
    IS 'Inserta un nuevo registro en la tabla cepat y devuelve el registro creado.';