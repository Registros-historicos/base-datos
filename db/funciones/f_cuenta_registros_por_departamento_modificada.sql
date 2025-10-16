create or replace function f_cuenta_registros_por_departamento()
    returns TABLE(departamento_param bigint, nombre_departamento varchar, total bigint)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY
        SELECT DISTINCT a_all.departamento_param,
               p.nombre AS nombre_departamento,
               COALESCE(conteos.total, 0)::BIGINT AS total
        FROM adscripcion a_all
        LEFT JOIN parametrizacion p ON p.id_param = a_all.departamento_param
        LEFT JOIN (
            SELECT a.departamento_param, COUNT(DISTINCT r.id_registro)::BIGINT AS total
            FROM registro r
                     JOIN registro_investigador ri ON ri.id_registro = r.id_registro
                     JOIN adscripcion a            ON a.id_investigador = ri.id_investigador
            GROUP BY a.departamento_param
        ) conteos ON conteos.departamento_param = a_all.departamento_param
        ORDER BY total DESC;
END;
$$;

comment on function f_cuenta_registros_por_departamento() is 'Conteo DISTINCT de registros agrupados por departamento_param (desde adscripcion).';

alter function f_cuenta_registros_por_departamento() owner to ci_owner;

grant execute on function f_cuenta_registros_por_departamento() to ci_app;

grant execute on function f_cuenta_registros_por_departamento() to ci_admin;