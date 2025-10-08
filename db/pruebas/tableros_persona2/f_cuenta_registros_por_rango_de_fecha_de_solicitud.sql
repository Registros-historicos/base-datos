-- Probar la función almacenada f_cuenta_registros_por_rango_de_fecha_de_solicitud


-- Agrupación pór semana
SELECT f_cuenta_registros_por_rango_de_fecha_de_solicitud('2023-01-01', '2023-01-31', 'semana') AS total_registros;

-- Agrupación por mes. Solo para rangos de mínimo 3 meses
SELECT f_cuenta_registros_por_rango_de_fecha_de_solicitud('2023-01-01', '2023-03-28', 'mes') AS total_registros;

-- Agrupación por año. Solo para rangos de mínimo 3 años
SELECT f_cuenta_registros_por_rango_de_fecha_de_solicitud('2023-01-01', '2025-12-31', 'año') AS total_registros;
