-- FUNCTION: public.f_busca_investigadores_por_coordinador(bigint)

CREATE OR REPLACE FUNCTION public.f_busca_investigadores_por_coordinador(
    p_id_usuario bigint) 
    RETURNS TABLE(
        id_investigador bigint, 
        curp character varying, 
        nombre character varying, 
        ape_pat character varying, 
        ape_mat character varying, 
        sexo_param bigint,
        tipo_investigador_param bigint 
    ) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        inv.id_investigador,
        inv.curp,
        inv.nombre,
        inv.ape_pat,
        inv.ape_mat,
        inv.sexo_param,
        inv.tipo_investigador_param
    FROM
        public.investigador AS inv
    JOIN
        public.adscripcion AS ads ON inv.id_investigador = ads.id_investigador
    JOIN
        public.institucion AS inst ON ads.id_institucion = inst.id_institucion
    WHERE
        inst.id_usuario = p_id_usuario; 
END;
$BODY$;

ALTER FUNCTION public.f_busca_investigadores_por_coordinador(bigint)
    OWNER TO ci_owner;

GRANT EXECUTE ON FUNCTION public.f_busca_investigadores_por_coordinador(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.f_busca_investigadores_por_coordinador(bigint) TO ci_admin;
GRANT EXECUTE ON FUNCTION public.f_busca_investigadores_por_coordinador(bigint) TO ci_app;
GRANT EXECUTE ON FUNCTION public.f_busca_investigadores_por_coordinador(bigint) TO ci_owner;