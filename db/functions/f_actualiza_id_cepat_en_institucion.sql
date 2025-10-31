-- FUNCTION: public.f_actualiza_id_cepat_institucion(bigint, bigint)

-- DROP FUNCTION IF EXISTS public.f_actualiza_id_cepat_institucion(bigint, bigint);

CREATE OR REPLACE FUNCTION public.f_actualiza_id_cepat_institucion(
	p_id_institucion bigint,
	p_nuevo_id_cepat bigint)
    RETURNS SETOF public.institucion 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
UPDATE public.institucion i
SET id_cepat = p_nuevo_id_cepat
WHERE i.id_institucion = p_id_institucion
RETURNING i.*; 
END;
$BODY$;

ALTER FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint) TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint) TO ci_app;

GRANT EXECUTE ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint) TO ci_owner;

COMMENT ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint)
    IS 'Actualiza el id_cepat de un registro de institución por su ID y devuelve el registro completo de la institución actualizada.';