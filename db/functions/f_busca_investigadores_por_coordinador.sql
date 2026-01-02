-- FUNCTION: public.f_busca_investigadores_por_coordinador(bigint)

DROP FUNCTION IF EXISTS public.f_busca_investigadores_por_coordinador(bigint);

CREATE OR REPLACE FUNCTION public.f_busca_investigadores_por_coordinador(
    p_id_usuario bigint)
    RETURNS TABLE(
        nombre text, 
        departamento text, 
        solicitudes bigint
    ) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        CONCAT(inv.nombre, ' ', inv.ape_pat, ' ', COALESCE(inv.ape_mat, ''))::text AS nombre,
        COALESCE(param_depto.nombre, 'Sin Asignar')::text AS departamento,
        (
            SELECT COUNT(ri.id_registro)
            FROM public.registro_investigador AS ri
            WHERE ri.id_investigador = inv.id_investigador
        ) AS solicitudes

    FROM
        public.investigador AS inv
    JOIN
        public.adscripcion AS ads ON inv.id_investigador = ads.id_investigador
    JOIN
        public.institucion AS inst ON ads.id_institucion = inst.id_institucion
    LEFT JOIN
        public.parametrizacion AS param_depto ON ads.departamento_param = param_depto.id_param
    WHERE
        inst.id_usuario = p_id_usuario; 
END;
$BODY$;

ALTER FUNCTION public.f_busca_investigadores_por_coordinador(bigint) OWNER TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_busca_investigadores_por_coordinador(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_busca_investigadores_por_coordinador(bigint) TO ci_app;