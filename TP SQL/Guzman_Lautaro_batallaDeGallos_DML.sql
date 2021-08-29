-- 1
SELECT sobrenombre, id, nombre 
    FROM competidor 
        NATURAL JOIN plaza 
WHERE ciudad= 'Quilmes'
;

--2
SELECT COUNT (rima.competicion_id) AS contar_competencia, sobrenombre, plaza.nombre 
    FROM competidor
        JOIN plaza ON plaza.id = competidor.plaza_id
        JOIN rima ON competidor.id = rima.competidor_id
GROUP BY competidor.sobrenombre, plaza.nombre
HAVING COUNT (competicion_id) =1
;

-- 3
SELECT nombre 
    FROM competicion 
        NATURAL JOIN tematica_en_competicion
        NATURAL JOIN tematica
WHERE duracion_en_segundos>120
;

-- 4
SELECT tematica.nombre, AVG(duracion_en_segundos) AS prom_duracion 
    FROM tematica 
        JOIN tematica_en_competicion ON tematica.id = tematica_en_competicion.tematica_id
        JOIN competicion ON competicion.id = tematica_en_competicion.competicion_id
WHERE predio='Colonial' 
    AND 
      provincia='Buenos Aires'
GROUP BY tematica.nombre

INTERSECT

SELECT tematica.nombre, AVG(duracion_en_segundos) AS prom_duracion 
    FROM tematica 
        JOIN tematica_en_competicion ON tematica.id = tematica_en_competicion.tematica_id
        JOIN competicion ON competicion.id = tematica_en_competicion.competicion_id
WHERE predio='Colonial' 
    AND 
      provincia='Cordoba'
GROUP BY tematica.nombre
;


-- 5
SELECT sobrenombre 
    FROM competidor  
EXCEPT
SELECT DISTINCT sobrenombre 
    FROM competidor 
        JOIN rima ON competidor.id = rima.competidor_id
;

-- 6
SELECT MAX(valoracion), competidor.sobrenombre 
    FROM rima 
        JOIN competidor ON  rima.competidor_id =competidor.id 
GROUP BY competidor.sobrenombre
INTERSECT
SELECT MAX(valoracion), competidor.sobrenombre 
    FROM competidor
        JOIN plaza ON competidor.plaza_id = plaza.id
        JOIN rima ON competidor.id = rima.competidor_id
        JOIN competicion ON competicion.id = rima.competicion_id
WHERE plaza.ciudad != competicion.ciudad 
GROUP BY competidor.sobrenombre
;

-- 7
SELECT AVG(rima.valoracion), tematica_id
    FROM tematica_en_competicion 
        NATURAL JOIN rima
GROUP BY tematica_en_competicion.tematica_id
HAVING AVG (rima.valoracion) <= 6.4
;

-- 8
SELECT DISTINCT beat_autor, beat_nombre, competicion.nombre 
    FROM tematica_en_competicion
        JOIN competicion ON competicion.id = tematica_en_competicion.competicion_id
        NATURAL JOIN rima 
WHERE rima.valoracion >= 2
;

-- 9
SELECT COUNT (plaza.id), (provincia, ciudad) AS Zona 
    FROM plaza
GROUP BY plaza.provincia, plaza.ciudad
ORDER BY Zona
;

-- 10
SELECT COUNT (competidor.id) AS num_competidores, (provincia, ciudad) AS Zona
    FROM rima
        JOIN competidor ON competidor.id = rima.competidor_id 
        JOIN plaza ON competidor.plaza_id = plaza.id 
GROUP BY  provincia, ciudad
ORDER BY num_competidores, Zona DESC
;

-- 11
SELECT MAX(valoracion) AS puntaje_max, MIN(valoracion) AS putanje_min, AVG(valoracion) AS puntaje_prom 
    FROM rima 
        JOIN competidor ON competidor.id = rima.competidor_id
        JOIN plaza ON competidor.plaza_id= plaza.id
GROUP BY plaza
;

-- 12
SELECT fecha_registro, sobrenombre, valoracion, beat_nombre, beat_autor, plaza_id 
    FROM rima
        JOIN competidor ON competidor.id = rima.competidor_id
        NATURAL JOIN tematica_en_competicion
ORDER BY fecha_registro DESC
LIMIT 10
;


-- 14 
CREATE VIEW competidores_historicos AS
SELECT sobrenombre 
    FROM rima 
        JOIN competidor ON rima.competidor_id = competidor.id
        JOIN competicion ON rima.competicion_id = competicion.id
WHERE provincia ='Buenos Aires' 
GROUP BY competidor.sobrenombre
HAVING AVG (valoracion) > 7


INTERSECT

SELECT sobrenombre 
    FROM competidor 
        JOIN rima ON rima.competidor_id = competidor.id
GROUP BY sobrenombre
HAVING COUNT (competicion_id) > 3
/* En este SELECT, no pude armar la consulta para que solo me devuelva los competidores que participaron en mas de 3 competencias, por alguna razon me termina
contando siempre la cantidad de rimas que estan registradas. En realidad ningun competidor participo en mas de 3 competencias.
*/
INTERSECT

SELECT sobrenombre 
    FROM competidor 
        JOIN rima ON rima.competidor_id = competidor.id
WHERE valoracion = 10
GROUP BY sobrenombre
HAVING COUNT (valoracion) >= 4

INTERSECT

SELECT sobrenombre 
    FROM competidor
        JOIN rima ON rima.competidor_id = competidor.id
WHERE fecha_registro < '01/01/2015' OR fecha_registro > '01/01/2020'
;

SELECT * 
    FROM competidores_historicos
;

--16
SELECT DISTINCT beat_nombre, beat_autor 
    FROM tematica_en_competicion
        NATURAL JOIN rima
        JOIN competidor ON competidor.id = rima.competidor_id
WHERE beat_autor = sobrenombre
;

-- 17 
CREATE VIEW suma_puntajes AS
SELECT SUM(valoracion) AS sum_val, competicion.nombre 
    FROM rima
        JOIN competicion ON rima.competicion_id = competicion.id
GROUP BY competicion.nombre
ORDER BY competicion.nombre
;

CREATE VIEW max_puntajes AS
SELECT sobrenombre, competicion.nombre, MAX(sum_val) 
    FROM suma_puntajes
        NATURAL JOIN competidor
        NATURAL JOIN competicion
GROUP BY competicion.nombre, competidor.sobrenombre
ORDER BY competicion.nombre
;

SELECT * 
    FROM max_puntajes
;