# 🤖 INSTRUCCIONES PARA EL AGENTE IA DE TURNO (HANDOFF)

Hola colega IA. Si estás leyendo esto, es porque el humano (el usuario "rey") está en una computadora nueva de la universidad preparándose para su presentación final o realizando pruebas.

**Tu misión primordial es configurar este proyecto para que corra a la perfección y a la primera en esta nueva máquina o en los servidores de la universidad.**

El proyecto "EnglishKids" es una app web educativa construida en Java (JSP, Servlets), HTML5, Bootstrap, CSS3 y PostgreSQL.

## 1. Conexión a Base de Datos (PostgreSQL)
* El usuario de base de datos requerido por la rúbrica de la universidad es: `usuario = alumno`
* La contraseña es: `clave = 1234`
* **MUY IMPORTANTE:** Tienes que revisar y editar inmediatamente el archivo `src/main/java/com/englishkids/db/DBConnection.java`.
  * Si la universidad pide conectarse al servidor remoto, la URL JDBC deberá ser: `jdbc:postgresql://172.17.42.121:5432/englishkids` (o la BD correspondiente).
  * Si es una prueba local, la URL será `jdbc:postgresql://localhost:5432/englishkids`.
  * Pregúntale al humano a cuál de los dos se van a conectar ahora.
* **Restaurar BD:** Si la prueba es local, dile al humano cómo correr el script `insert_demo.sql` (ubicado en la raíz de este proyecto) para regenerar las tablas y datos usando psql o pgAdmin.

## 2. Compilación y Despliegue (Servidor Tomcat 9)
* Este proyecto debe empaquetarse en un archivo `.war`. Puedes usar Maven (si detectas el `pom.xml`) ejecutando `mvn clean package`.
* **Despliegue de Presentación Final:** La rúbrica exige subir el archivo `.war` al Servidor Web Tomcat con la IP **172.17.42.107:8085** usando las credenciales `usuario=admin` y `clave=admin`.
  * Puedes guiar al humano para que entre a `http://172.17.42.107:8085/manager/html` y suba el `.war` manualmente, o intentar automatizarlo con un comando CURL hacia el Tomcat Manager si estás en la terminal.

## 3. Subida a GitHub
* La rúbrica pide subir el proyecto y el script de la base de datos a GitHub. 
* Si el humano aún no lo ha subido, crea un `.gitignore` correcto para proyectos Java/Eclipse/Maven (ignorando `.class`, `target/`, `.settings/`, etc.), inicializa el repositorio con `git init`, añade los archivos, haz el commit y ayúdalo a configurar el `git remote add origin <URL>`.

## 4. Lo que NO debes romper
* Todo el código Frontend (CSS, JS, JSPs) ya fue programado y validado. Cumple con la rúbrica.
* Hay un widget de accesibilidad inyectado en `src/main/webapp/js/main.js` (Lector de pantalla, daltonismo, texto grande). NO lo borres, es fundamental para sus 2 puntos de accesibilidad.

## TU PRIMER PASO AHORA:
Preséntate al usuario, dile que leíste el `AI_HANDOFF.md`, e infórmale que estás listo. Hazle estas dos preguntas para iniciar:
1. "¿Apuntamos la base de datos al localhost de esta computadora o directo a la IP de la universidad (172.17.42.121)?"
2. "¿Generamos de una vez el archivo .WAR para subirlo al Tomcat de la universidad (172.17.42.107)?"

¡A trabajar, IA! Haz que el humano se saque 20/20.
