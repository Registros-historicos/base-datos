-- 1. ELIMINA LA FUNCIÓN ANTIGUA (con 2 parámetros)
DROP FUNCTION IF EXISTS public.f_actualiza_id_cepat_institucion(bigint, bigint);

-- 2. CREA O REEMPLAZA LA NUEVA FUNCIÓN (con 3 parámetros)
CREATE OR REPLACE FUNCTION public.f_actualiza_id_cepat_institucion(
	p_id_institucion bigint,
	p_nuevo_id_cepat bigint,
	p_nuevo_id_coordinador bigint) -- <-- PARÁMETRO AÑADIDO
    RETURNS SETOF institucion 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY
UPDATE public.institucion i
SET 
    id_cepat = p_nuevo_id_cepat,
    id_coordinador = p_nuevo_id_coordinador -- <-- CAMPO AÑADIDO
WHERE i.id_institucion = p_id_institucion
RETURNING i.*; 
END;
$BODY$;

-- 3. ACTUALIZA PERMISOS Y COMENTARIOS PARA LA NUEVA FIRMA (3 parámetros)
ALTER FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint, bigint)
    OWNER TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint, bigint) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint, bigint) TO ci_admin;

GRANT EXECUTE ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint, bigint) TO ci_app;

GRANT EXECUTE ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint, bigint) TO ci_owner;

COMMENT ON FUNCTION public.f_actualiza_id_cepat_institucion(bigint, bigint, bigint)
    IS 'Actualiza el id_cepat y el id_coordinador de un registro de institución por su ID y devuelve el registro completo de la institución actualizada.'; -- <-- COMENTARIO ACTUALIZADO