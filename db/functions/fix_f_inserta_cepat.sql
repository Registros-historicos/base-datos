-- FUNCTION: public.f_inserta_cepat(character varying, bigint)
DROP FUNCTION IF EXISTS public.f_inserta_cepat(character varying, bigint);

CREATE OR REPLACE FUNCTION public.f_inserta_cepat(
	p_nombre character varying,
	p_id_usuario bigint) 
    RETURNS TABLE(id_cepat bigint, nombre character varying, id_usuario bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
INSERT INTO cepat(nombre, id_usuario) 
VALUES (p_nombre, p_id_usuario) 
RETURNING 
    cepat.id_cepat,
    cepat.nombre,
    cepat.id_usuario; 
END;
$BODY$;

ALTER FUNCTION public.f_inserta_cepat(character varying, bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_inserta_cepat(character varying, bigint) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.f_inserta_cepat(character varying, bigint) TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_inserta_cepat(character varying, bigint) TO ci_app;

GRANT EXECUTE ON FUNCTION public.f_inserta_cepat(character varying, bigint) TO ci_owner;

COMMENT ON FUNCTION public.f_inserta_cepat(character varying, bigint)
    IS 'Inserta un nuevo registro en la tabla cepat (nombre e id_coordinador) y devuelve el registro creado.'; -- <-- COMENTARIO ACTUALIZADO