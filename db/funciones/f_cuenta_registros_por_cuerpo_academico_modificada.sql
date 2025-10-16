create or replace function f_cuenta_registros_por_cuerpo_academico()
    returns TABLE(cuerpo_academico_param bigint, nombre_cuerpo_academico varchar, total bigint)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY
        SELECT DISTINCT a_all.cuerpo_academico_param,
               p.nombre AS nombre_cuerpo_academico,
               COALESCE(conteos.total, 0)::BIGINT AS total
        FROM adscripcion a_all
        LEFT JOIN parametrizacion p ON p.id_param = a_all.cuerpo_academico_param
        LEFT JOIN (
            SELECT a.cuerpo_academico_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
            FROM registro r
                     JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                     JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
            GROUP BY a.cuerpo_academico_param
        ) conteos ON conteos.cuerpo_academico_param = a_all.cuerpo_academico_param
        ORDER BY total DESC;
END;
$$;

comment on function f_cuenta_registros_por_cuerpo_academico() is 'Conteo DISTINCT de registros agrupados por cuerpo_academico_param (desde adscripcion).';

alter function f_cuenta_registros_por_cuerpo_academico() owner to ci_owner;

grant execute on function f_cuenta_registros_por_cuerpo_academico() to ci_app;

grant execute on function f_cuenta_registros_por_cuerpo_academico() to ci_admin;