INSERT INTO parametrizacion (id_param, id_tema, nombre)
VALUES (230, 1, 'Otro')
ON CONFLICT (id_param) DO NOTHING;
