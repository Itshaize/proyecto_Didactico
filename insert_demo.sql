INSERT INTO usuarios (nombre, apellido, correo, clave, perfil, activo) 
SELECT 'Administrador', 'Demo', 'admin@englishkids.edu', '60fe74406e7f353ed979f350f2fbb6a2e8690a5fa7d1b0c32983d1d8b3f95f67', 'ADMIN', true
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE correo = 'admin@englishkids.edu');

INSERT INTO usuarios (nombre, apellido, correo, clave, perfil, activo) 
SELECT 'Estudiante', 'Demo', 'estudiante@englishkids.edu', 'f69f07acac7f01df188c16bf3d984fd7b99eb2c5786255053690e1b6da842824', 'ESTUDIANTE', true
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE correo = 'estudiante@englishkids.edu');
