--- Exercici 2 
--- NIVELL 1
--- Utilitzant JOIN realitzaràs les següents consultes:
--- Llistat dels països que estan fent compres.

SELECT DISTINCT c.country 
FROM company c
INNER JOIN transaction t ON c.id = t.company_id;

--- Des de quants països es realitzen les compres.

SELECT COUNT(DISTINCT c.country) AS num_paisos
FROM company c
INNER JOIN transaction t ON c.id = t.company_id;

--- Identifica la companyia amb la mitjana més gran de vendes.

SELECT t.company_id, c.company_name, round(AVG(t.amount)) AS mitjana_mes_gran
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY t.company_id
ORDER BY mitjana_mes_gran DESC
LIMIT 1;

--- Exercici 3 ( con subconsultas)
--- Mostra totes les transaccions realitzades per empreses d Alemanya 

SELECT id, company_id
FROM transaction
WHERE company_id IN (SELECT id
					FROM company
					WHERE country = 'germany') 
AND transaction.declined = 0                    
ORDER BY id DESC;

--- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT id, company_name
FROM company
WHERE id IN (SELECT company_id
			FROM transaction
            WHERE amount >( SELECT AVG(amount) 
							FROM transaction) 
			AND transaction.declined = 0);

--- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat daquestes empreses.
--- CAMBIAR A NOT EXISTS

SELECT * 
FROM COMPANY c
WHERE c.id NOT IN ( SELECT company_id FROM transaction);

--- NIVELL 2
--- Exercici 1  Identifica els cinc dies que es va generar la quantitat més gran dingressos a lempresa per vendes. 
--- Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) AS Data, SUM(amount) AS Total
FROM transaction
WHERE declined = 0
GROUP BY DATA
ORDER BY total DESC
LIMIT 5;

--- Exercici 2 Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT company.country, ROUND(AVG(transaction.amount)) AS mitjana_vendes
FROM transaction
JOIN company ON company.id = transaction.company_id
WHERE transaction.declined = 0
GROUP BY company.country
ORDER BY mitjana_vendes DESC;

--- Exercici 3 En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
--- per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions 
--- realitzades per empreses que estan situades en el mateix país que aquesta companyia.

--- Mostra el llistat aplicant JOIN i subconsultes.
SELECT transaction.id, company.country, company.company_name
FROM transaction 
JOIN company on company.id = transaction.company_id
WHERE company.country = (SELECT country FROM company WHERE company_name = "Non Institute") 
AND transaction.declined = 0;

--- Mostra el llistat aplicant solament subconsultes.

SELECT transaction.id, c.country, c.company_name
FROM transaction , ( SELECT * FROM COMPANY) c
WHERE c.country = (SELECT country 
					FROM company
					WHERE company_name = "Non Institute") 
AND c.id = transaction.company_id
AND transaction.declined = 0
GROUP BY transaction.id, c.country, c.company_name;

--- Nivell 3
--- Exercici 1 Presenta el nom, telèfon, país, data i amount, d aquelles empreses que van realitzar transaccions amb un 
--- valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de 
--- març del 2022. Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone, c.country, t.timestamp, t.amount
FROM company c
JOIN TRANSACTION t ON t.company_id = c.id
WHERE t.amount between 100 and 200
AND DATE(t.timestamp) IN ('2021-04-29','2021-7-20','2022-3-13')
AND t.declined = 0
ORDER BY t.AMOUNT DESC; 

--- Exercici 2 Necessitem optimitzar l assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
--- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
--- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més 
--- de 4 transaccions o menys.

SELECT c.company_name, count(t.id) AS cantidad, IF( count(t.id) >= 4, 'Mas de 4', 'Menos de 4') AS Total_transaccions
FROM transaction t
JOIN company c ON t.company_id = c.id
GROUP BY c.company_name
ORDER BY cantidad DESC;








