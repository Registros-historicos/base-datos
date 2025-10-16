CREATE OR REPLACE FUNCTION f_busca_registros_por_tipo(
    p_tipo_registro_param int,
    p_limit integer, 
    p_offset integer, 
    p_sort_column character varying DEFAULT 'fec_solicitud'::character varying, 
    p_sort_order character varying DEFAULT 'DESC'::character varying
)
RETURNS TABLE(
    id_registro bigint, no_expediente bigint, titulo character varying, 
    tipo_ingreso_param bigint, id_usuario bigint, rama_param bigint, 
    fec_expedicion timestamp without time zone, observaciones character varying, 
    archivo character varying, estatus_param bigint, medio_ingreso_param bigint, 
    tipo_registro_param bigint, fec_solicitud timestamp without time zone, 
    descripcion character varying, tipo_sector_param bigint, institucion character varying
)
LANGUAGE plpgsql AS $$
DECLARE
    v_allowed_cols CONSTANT text[] := ARRAY[
        'id_registro','no_expediente','titulo','fec_expedicion','fec_solicitud','descripcion'
    ];
    v_sort_col text;
    v_sort_dir text;
    v_limit int;
    v_offset int;
    v_sql text;
BEGIN
    v_sort_dir := CASE lower(coalesce(p_sort_order,'desc'))
        WHEN 'asc' THEN 'ASC'
        WHEN 'desc' THEN 'DESC'
        ELSE 'DESC'
    END;

    v_sort_col := CASE
        WHEN p_sort_column = ANY(v_allowed_cols) THEN p_sort_column
        ELSE 'fec_solicitud'
    END;

    v_limit := GREATEST(0, LEAST(coalesce(p_limit,50),1000));
    v_offset := GREATEST(0, coalesce(p_offset,0));

    v_sql := format($fmt$
        SELECT DISTINCT
            r.id_registro, r.no_expediente, r.titulo,
            r.tipo_ingreso_param, r.id_usuario, r.rama_param,
            r.fec_expedicion, r.observaciones, r.archivo,
            r.estatus_param, r.medio_ingreso_param,
            r.tipo_registro_param, r.fec_solicitud,
            r.descripcion, r.tipo_sector_param,
            COALESCE(i.nombre, '-') AS institucion
        FROM registro r
        LEFT JOIN registro_investigador ri ON ri.id_registro = r.id_registro
        LEFT JOIN adscripcion a ON a.id_investigador = ri.id_investigador
        LEFT JOIN institucion i ON i.id_institucion = a.id_institucion
        WHERE r.tipo_registro_param = $1
          AND r.estatus_param != 25
        ORDER BY %I %s
        LIMIT $2 OFFSET $3
    $fmt$, v_sort_col, v_sort_dir);

    RETURN QUERY EXECUTE v_sql
        USING p_tipo_registro_param, v_limit, v_offset;
END;
$$;

alter function f_cuenta_registros_por_tipo(bigint) owner to ci_owner;

grant execute on function f_cuenta_registros_por_tipo(bigint) to ci_app;

grant execute on function f_cuenta_registros_por_tipo(bigint) to ci_admin;