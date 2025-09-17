
-- ********* Nivell 1 ***********
-- Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:

USE transactions;

-- Llistat dels països que estan generant vendes. 
SELECT DISTINCT country FROM company c
INNER JOIN transaction t ON c.id = t.company_id
order by country;

-- Des de quants països es generen les vendes. 
SELECT count(DISTINCT country) FROM company c
INNER JOIN transaction t ON c.id = t.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT t.company_id,c.company_name, AVG(amount) mitjana_vendes 
FROM transaction t, company c
WHERE c.id = t.company_id
GROUP BY t.company_id
ORDER BY AVG(amount) DESC
LIMIT 1;

-- Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT t.* 
FROM transaction t, company c
WHERE c.id = t.company_id and c.country='Germany';

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT DISTINCT(c.id),c.company_name from company c, transaction t
where t.company_id = c.id and t.amount > ( SELECT AVG(amount) FROM transaction )
order by id;

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT DISTINCT(c.id),c.company_name FROM company c , transaction t
WHERE c.id not in (SELECT DISTINCT t.company_id FROM transaction t);

-- ********* Nivell 2 ***********
-- Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE_FORMAT(t.timestamp, '%e %b %Y') , sum(t.amount)
FROM transaction t
GROUP BY timestamp
ORDER BY sum(t.amount) DESC
LIMIT 5;

-- Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT c.country,  AVG(t.amount)
FROM transaction t, company c
WHERE  c.id = t.company_id
GROUP BY c.country
ORDER BY AVG(t.amount) DESC;

-- Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia

-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT COUNT(*) -- t.*
FROM transaction t
INNER JOIN company c ON c.id = t.company_id
WHERE c.country = (SELECT c2.country FROM company c2 WHERE c2.company_name='Non Institute');

-- Mostra el llistat aplicant solament subconsultes.
SELECT COUNT(*) -- t.*
FROM transaction t, company c
WHERE c.id = t.company_id AND c.country = (SELECT c2.country FROM company c2 WHERE c2.company_name='Non Institute');


-- **************** Nivell 3 ***********************
-- Exercici 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 
-- 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
-- Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone , c.country, DATE_FORMAT(t.timestamp,'%d/%m/%Y'), t.amount
FROM company c , transaction t
WHERE c.id = t.company_id AND t.amount BETWEEN 350 AND 400 AND DATE_FORMAT(t.timestamp,'%d/%m/%Y') IN('29/04/2015','20/07/2018','13/03/2024')
ORDER BY t.amount DESC;

-- Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.

SELECT company_id AS "Id de COMPANYIA" , IF(NUM_TX > 400, "COMPANYIA AMB MES DE 400 TX" , "COMPANYIA AMB 400 O MENYS TX") AS " MES O MENYS DE 400 TX"
FROM ( 
		SELECT t.company_id, COUNT(*) as NUM_TX
		FROM transaction t
		GROUP BY t.company_id
        ) AS compxtx
;





