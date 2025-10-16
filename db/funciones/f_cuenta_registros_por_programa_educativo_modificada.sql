create or replace function f_cuenta_registros_por_programa_educativo()
    returns TABLE(programa_educativo_param bigint, nombre_programa_educativo varchar, total bigint)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY
        SELECT DISTINCT a_all.programa_educativo_param,
               p.nombre AS nombre_programa_educativo,
               COALESCE(conteos.total, 0)::BIGINT AS total
        FROM adscripcion a_all
        LEFT JOIN parametrizacion p ON p.id_param = a_all.programa_educativo_param
        LEFT JOIN (
            SELECT a.programa_educativo_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
            FROM registro r
                     JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                     JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
            GROUP BY a.programa_educativo_param
        ) conteos ON conteos.programa_educativo_param = a_all.programa_educativo_param
        ORDER BY total DESC;
END;
$$;

comment on function f_cuenta_registros_por_programa_educativo() is 'Conteo DISTINCT de registros agrupados por programa_educativo_param (desde adscripcion).';

alter function f_cuenta_registros_por_programa_educativo() owner to ci_owner;

grant execute on function f_cuenta_registros_por_programa_educativo() to ci_app;

grant execute on function f_cuenta_registros_por_programa_educativo() to ci_admin;
