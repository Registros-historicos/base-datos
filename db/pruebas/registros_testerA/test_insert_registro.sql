-- Script de prueba para las funciones de Altas y Ediciones


-- Prueba de inserción de un nuevo registro f_inserta_nuevo_registro
SELECT *
FROM f_inserta_nuevo_registro(
        12345, -- p_no_expediente
        'Registro de Prueba', -- p_titulo
        1, -- p_tipo_ingreso_param
        1, -- p_id_usuario
        1, -- p_rama_param
        '2024-01-15 10:30:00'::timestamp, -- p_fec_expedicion
        'Observaciones de prueba', -- p_observaciones
        'archivo_prueba.pdf', -- p_archivo
        1, -- p_estatus_param (activo)
        1, -- p_medio_ingreso_param
        44, -- p_tipo_registro_param (IMPI)
        '2024-01-10 09:00:00'::timestamp, -- p_fec_solicitud
        'Descripción del registro de prueba', -- p_descripcion
        1 -- p_tipo_sector_param
     );

-- Prueba de actualización de un registro existente f_actualiza_registro
SELECT *
FROM f_actualiza_resgistro_por_pk(
        1006, -- p_id_registro
        12345, -- p_no_expediente
        'Registro de Prueba Actualizado', -- p_titulo
        1, -- p_tipo_ingreso_param
        1, -- p_id_usuario
        1, -- p_rama_param
        '2024-01-15 10:30:00'::timestamp, -- p_fec_expedicion
        'Observaciones de prueba actualizadas', -- p_observaciones
        'archivo_prueba_actualizado.pdf', -- p_archivo
        27, -- p_estatus_param (pendiente)
        1, -- p_medio_ingreso_param
        44, -- p_tipo_registro_param (IMPI)
        '2024-01-10 09:00:00'::timestamp, -- p_fec_solicitud
        'Descripción del registro de prueba actualizada', -- p_descripcion
        1 -- p_tipo_sector_param
     );

-- Prueba de deshabilitación de un registro existente f_deshabilita_registro
SELECT *
FROM f_deshabilita_registro(
        1006, -- p_id_registro
        29 -- p_estatus_deshabilitado (Rechazada)
     );

-- Prueba de habilitación de un registro existente f_habilita_registro
SELECT *
FROM f_habilita_registro(
        1006, -- p_id_registro
        27 -- p_estatus_habilitado (Activo)
     );