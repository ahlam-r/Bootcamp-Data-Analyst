/*Nivell 1
Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals
puguis realitzar les següents consultes:*/

---  CREO TAULA USERS 
/*USO DE LA BBDD*/
USE sprint4;
/*USERS*/
CREATE TABLE IF NOT EXISTS users(id INT PRIMARY KEY, 
                        name CHAR(20) NULL, 
                        surname CHAR(50) NULL,
                        phone VARCHAR(15) NULL,
                        email VARCHAR (50) NULL,
                        birth_date VARCHAR (20),
                        country CHAR(20) NULL,
                        city CHAR(50) NULL,
                        postal_code VARCHAR(15) NULL,
                        address VARCHAR(255) NULL);   
                        
#COM HEM DONAVA ERROR HE UTILIZAT ELS SEGUENTS PER SOLUCIONAR INCIDENCIES PER PODER CAREGAR LES DADES 

SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'basedir';
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';                           
                        
--- CARGO USA 
 
LOAD DATA LOCAL INFILE "C:/Users/ahlam/Desktop/DATA ANALYST Bootcamp/Sprint 4/users_usa.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'  -- 
IGNORE 1 LINES;                        
 
--- CARGO UK 

LOAD DATA LOCAL INFILE  "C:/Users/ahlam/Desktop/DATA ANALYST Bootcamp/Sprint 4/users_uk.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'  -- 
IGNORE 1 LINES;  

--- CARGO CANADA

LOAD DATA LOCAL INFILE  "C:/Users/ahlam/Desktop/users_ca.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'  -- 
IGNORE 1 LINES;  
                     
--- CREO TABLA CREDIT_CARDS				
/*USO DE LA BBDD*/
USE sprint4;

/*CREACION DE TABLAS*/
/*CREDIT_CARDS*/
CREATE TABLE IF NOT EXISTS credit_cards(id VARCHAR(10) PRIMARY KEY, 
                        user_id INT NULL, 
                        iban VARCHAR(40) NULL,
                        pan VARCHAR(20) NULL,
                        pin VARCHAR(4) NULL,
                        cvv INT NULL,
                        track1 VARCHAR(255) NULL,
                        track2 VARCHAR(255) NULL,
                        expiring_date VARCHAR(10) NULL);


-- DATOS TABLA CREDIT_CARDS 

LOAD DATA LOCAL INFILE  "C:/Users/ahlam/Desktop/DATA ANALYST Bootcamp/Sprint 4/credit_cards.csv"
INTO TABLE credit_cards 
FIELDS TERMINATED BY ','   
IGNORE 1 LINES;  

-- CREO TAULA COMPANIES                     
/*USO DE LA BBDD*/
USE sprint4;
/*CREACION DE TABLAS*/
/*COMPANIES*/
CREATE TABLE IF NOT EXISTS companies(company_id VARCHAR(6) PRIMARY KEY, 
                        company_name VARCHAR (255), 
                        phone VARCHAR(20) NULL,
                        email VARCHAR(50),
                        country VARCHAR(50) NULL,
                        website VARCHAR(100) NULL);


-- DADES TAULA COMPANIES

LOAD DATA LOCAL INFILE  "C:/Users/ahlam/Desktop/DATA ANALYST Bootcamp/Sprint 4/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'  -- 
IGNORE 1 LINES;  

-- CREO TAULA PRODUCTS                     
/*USO DE LA BBDD*/
USE sprint4;
/*CREACION DE TABLAS*/
/*PRODUCTS*/CREATE TABLE IF NOT EXISTS products(id INT PRIMARY KEY, 
                        product_name VARCHAR (50) NULL, 
                        price varchar(10) NULL,
                        colour VARCHAR(20),
                        weight FLOAT NULL,
                        warehouse_id VARCHAR(10) NULL);


-- DADES TAULA PRODUCTS

LOAD DATA LOCAL INFILE  "C:/Users/ahlam/Desktop/DATA ANALYST Bootcamp/Sprint 4/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','  
IGNORE 1 LINES;  

--- CARGO TABLA TRANSACTIONS					
/*USO DE LA BBDD*/
USE sprint4;

/*CREACION DE TABLAS*/
/*TRANSACTIONS*/
CREATE TABLE IF NOT EXISTS transactions(id VARCHAR(50) PRIMARY KEY, 
                        card_id VARCHAR(10) NULL, 
                        business_id VARCHAR(6) NULL,
                        timestamp TIMESTAMP NULL,
                        amount FLOAT,
                        declined TINYINT,
                        product_ids TEXT NULL,
                        user_id INT NULL,
                        lat VARCHAR(255) NULL,
                        longitude VARCHAR(255) NULL,
FOREIGN KEY (card_id) REFERENCES credit_cards (id),
FOREIGN KEY (business_id) REFERENCES companies (company_id),
FOREIGN KEY (user_id) REFERENCES users (id)
);  

--- DATOS TABLA TRANSACTIONS

LOAD DATA LOCAL INFILE "C:/Users/ahlam/Desktop/DATA ANALYST Bootcamp/Sprint 4/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Exercici 1 Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules

SELECT name, id
FROM users
WHERE id IN ( SELECT USER_ID 
			FROM transactions
			GROUP BY user_id
			HAVING COUNT(ID) > 30);

-- Exercici 2 Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT cc.IBAN, ROUND(AVG(T.AMOUNT),2) AS MITJANA ,c.company_name
FROM credit_cards CC
JOIN transactions T ON t.card_id = cc.id
JOIN companies C ON t.business_id = c.company_id
WHERE company_name = "Donec Ltd" AND DECLINED = 0
GROUP BY  cc.IBAN, c.company_name;

-- sense declined = 0

SELECT cc.IBAN, ROUND(AVG(T.AMOUNT),2) AS MITJANA ,c.company_name
FROM credit_cards CC
JOIN transactions T ON t.card_id = cc.id
JOIN companies C ON t.business_id = c.company_id
WHERE company_name = "Donec Ltd" 
GROUP BY  cc.IBAN, c.company_name;

-- Nivell 2 Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser 
-- declinades i genera la següent consulta:

USE sprint4;
CREATE TABLE card_status AS
SELECT cc.id,  CASE WHEN SUM(CASE WHEN t.declined = 1 THEN 1 ELSE 0 END) = 3 THEN 'Inactive'ELSE 'Active'END AS status
FROM credit_cards CC
JOIN transactions T ON T.card_id = CC.id
WHERE cc.id in (SELECT tmp_table.id FROM
(SELECT cc1.id, t1.timestamp from transactions t1 inner join credit_cards cc1 on t1.card_id = cc1.id
where cc1.id = cc.id
order by t1.card_id, t1.timestamp DESC
LIMIT 3) tmp_table)
group by cc.id;

# MODIFICAR TAULA card_status PER UNIRLA AMB TRANSACTION
ALTER TABLE card_status 
  ADD FOREIGN KEY(id)
  REFERENCES credit_cards(id);

-- Exercici 1 Quantes targetes estan actives?*/

SELECT COUNT(STATUS) as targetes_actives
FROM card_status
WHERE status = 'Active';

-- ROW NUMBER ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber / ROW_NUMBER() OVER(PARTITION BY SalesTerritoryKey 
        -- ORDER BY SUM(SalesAmountQuota) DESC) AS RowNumber

CREATE TABLE card_status1 AS;

SELECT card_id,  CASE WHEN SUM(CASE WHEN declined = 1 THEN 1 ELSE 0 END) = 3 THEN 'Inactive'ELSE 'Active'END AS status
FROM (SELECT Card_id, Declined,
        ROW_NUMBER () OVER (PARTITION BY Card_id ORDER BY Timestamp DESC) AS TransOrd
    FROM transactions) AS TransTime
WHERE TransOrd <= 3
GROUP BY Card_id;

CREATE TABLE CCStatus (
SELECT Card_id, IF(SUM(Declined)=3,"Cancel·lada","Activa") AS Estat
FROM (
    SELECT Card_id, Declined,
        ROW_NUMBER () OVER (PARTITION BY Card_id ORDER BY Timestamp DESC) AS TransOrd
    FROM transactions) AS TransTime
WHERE TransOrd <= 3
GROUP BY Card_id);


