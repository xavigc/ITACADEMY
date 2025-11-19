-- ****************** Nivell 1 **************************

-- Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
-- usuaris
    -- Creamos la base de datos
	-- DROP DATABASE vendes;
    CREATE DATABASE IF NOT EXISTS vendes;
    USE vendes;

    -- DROP TABLE transactions;
    -- DROP TABLE companies;
    -- DROP TABLE credit_cards;
	-- DROP TABLE european_users;       

    -- Creamos las tablas 
	
    CREATE TABLE IF NOT EXISTS users (
        id 			VARCHAR(255) PRIMARY KEY,
		name 		VARCHAR(100),
		surname 	VARCHAR(100),
		phone 		VARCHAR(30),
		email 		VARCHAR(50),
		birth_date 	VARCHAR(25),
		country 	VARCHAR(50),
		city 		VARCHAR(50),
		postal_code VARCHAR(10),
		address 	VARCHAR(255)          
    );
   
    CREATE TABLE IF NOT EXISTS credit_cards (
	id 				VARCHAR(255) PRIMARY KEY,
	user_id 		VARCHAR(255), 
    iban 			VARCHAR(255),
    pan				VARCHAR(255),
    pin				VARCHAR(4),
    cvv				VARCHAR(3),
	track1			VARCHAR(255),
	track2			VARCHAR(255),
    expiring_date	VARCHAR(25)
);

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS companies (
        id 		VARCHAR(255) PRIMARY KEY,
        name 	VARCHAR(255),
        phone 	VARCHAR(15),
        email 	VARCHAR(50),
        country VARCHAR(50),
        website VARCHAR(255)
    );

    
    -- Creamos la tabla transactions
    CREATE TABLE IF NOT EXISTS transactions (
        id 			VARCHAR(255) PRIMARY KEY,
        card_id 	VARCHAR(255), 
        business_id VARCHAR(255),
        date_tx		VARCHAR(25),
		amount 		DECIMAL(10, 2),
        declined 	BOOLEAN,
        product_ids VARCHAR(255) ,
		user_id 	VARCHAR(255) ,
        lat 		VARCHAR(255),
        longitude 	VARCHAR(255),
        FOREIGN KEY (card_id) 		REFERENCES credit_cards(id),
        FOREIGN KEY (business_id) 	REFERENCES companies(id),
        FOREIGN KEY (user_id) 		REFERENCES users(id)  
    );

SHOW VARIABLES LIKE "secure_file_priv";
SELECT @@GLOBAL.secure_file_priv;
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/european_users.csv" INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address)
-- SET birth_date = DATE_FORMAT(@birth_date, '%b %d, %Y')
; 

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/american_users.csv" INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address)
-- SET birth_date = DATE_FORMAT(@birth_date, '%b %d, %Y')
; 

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv" INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(`id`, `user_id`, `iban`, `pan`, `pin`, `cvv`, `track1`, `track2`, `expiring_date`)
; 

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv" INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(`id`, `name`, `phone`, `email`, `country`, `website`)
; 
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv" INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(`id`, `card_id`, `business_id`, `date_tx`, `amount`, `declined`, `product_ids`, `user_id`, `lat`, `longitude`)
; 

-- Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT u.id, count(u.id) num_tx FROM european_users u
JOIN transactions t ON user_id = u.id 
GROUP BY u.id 
HAVING count(*) > 80;

SELECT id FROM european_users 
WHERE id IN(
				SELECT user_id FROM transactions
				GROUP BY user_id
				HAVING count(*) >80
);


-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT iban,AVG(amount),count(*) FROM transactions t 
JOIN credit_cards cc ON cc.id = card_id
JOIN companies c ON  c.id = t.business_id AND name = 'Donec Ltd'
GROUP BY iban; 

-- ****************** Nivell 2 **************************
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions han estat declinades aleshores és inactiu, 
-- si almenys una no és rebutjada aleshores és actiu. 

    -- DROP TABLE estat_credit_cards;
  -- CREATE TABLE IF NOT EXISTS estat_credit_cards 
	WITH ultims AS ( 
					SELECT card_id, date_tx, declined , 
						   ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero 
					FROM transactions
					WHERE declined=1
					order by card_id,rank_numero
					) 
	SELECT card_id , 0 AS estat FROM ultims ul WHERE EXISTS (SELECT card_id WHERE rank_numero =3 AND card_id = ul.card_id)
	UNION
	SELECT DISTINCT(card_id), 1 AS estat FROM transactions WHERE card_id NOT IN ( SELECT card_id FROM ultims ul WHERE EXISTS (SELECT card_id WHERE rank_numero =3 AND card_id = ul.card_id) )
						 GROUP BY card_id
					 ORDER BY card_id;
    
  
	SELECT card_id, (CASE WHEN declined=1 THEN IF(max_rank=3, 1, 0) 
						  ELSE 0
					END) AS estat
	FROM(SELECT card_id, declined, MAX(rank_numero) AS max_rank
					FROM ( SELECT card_id, declined, ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero 
							FROM transactions
						 ) ultims
					 WHERE (rank_numero <=3 and declined=1) OR declined=0
					 GROUP BY card_id,declined
					 ORDER BY card_id,declined DESC
		) as ultims_ranked
	;
SELECT card_id, (CASE WHEN declined=1 THEN IF(max_rank=3, 1, 0) 
						  ELSE 0
					END) AS estat
FROM(    
SELECT card_id, declined, MAX(rank_numero) max_rank
		FROM (SELECT card_id, declined, ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero 
					  FROM transactions
			  ) ultims
		WHERE (rank_numero <=3 and declined=1) OR declined=0
		GROUP BY card_id,declined
		ORDER BY card_id,declined DESC
) ultims_ranked
GROUP BY card_id,estat;

SELECT card_id, (CASE WHEN declined=1 THEN IF(max_rank=3, 1, 0) 
						  ELSE 0
					END) AS estat 
FROM(
SELECT card_id, declined,max(rank_numero) max_rank
FROM(	SELECT * FROM ( SELECT card_id, declined, ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero 
							  FROM transactions
					  ) ultims
		WHERE rank_numero <=3
	) ultims3_ranked
GROUP BY card_id, declined) a 
WHERE max_rank=3;

SELECT card_id, declined, ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero 
					  FROM transactions;




-- Exercici 1
-- Quantes targetes estan actives?
SELECT COUNT(*) FROM estat_credit_cards WHERE estat=1;

-- ****************** Nivell 3 **************************
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. 

    -- Creamos la tabla products
	-- DROP TABLE products;
    CREATE TABLE IF NOT EXISTS products (
        id 				VARCHAR(255) PRIMARY KEY REFERENCES transactions(product_id),
        product_name 	VARCHAR(255),
        price 			VARCHAR(255),
        colour 			VARCHAR(50),
        weight 			VARCHAR(50),
        warehouse_id 	VARCHAR(255)
        ); -- id	product_name	price	colour	weight	warehouse_id


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv" INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(`id`,`product_name`,`price`,`colour`,`weight`,`warehouse_id`)
;

-- Genera la següent consulta:

-- Exercici 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT p.id,count(*) unitats_venudes FROM transactions
INNER JOIN products p ON CONCAT(', ',product_ids,',') like CONCAT('%, ', p.id ,',%')
GROUP BY p.id
ORDER BY unitats_venudes DESC; 

-- 253391(Total registres)

SHOW DATABASES;
SELECT p.id, CONCAT(', ',product_ids,',') like CONCAT('%, ', p.id ,',%') FROM transactions
INNER JOIN products p ON CONCAT(', ',product_ids,',') like CONCAT('%, ', p.id ,',%')
GROUP BY p.id
ORDER BY unitats_venudes DESC; 

Select * from transactions;
select * from products;

SELECT -- id,product_ids, 
SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 1), ',', -1) as  primer, 
IF (LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 2, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1),0) as segon, 
IF (LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 3, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1),0) as tercer,
IF (LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 4, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1),0) as quart,
IF (LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 5, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 5), ',', -1),0) as cinque, 
IF (LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 6, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 6), ',', -1),0) as sise 
-- SUBSTRING_INDEX(product_ids, ',' , 5) as fin, LENGTH(product_ids) ,
-- LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1
from transactions
where id='00043A49-2949-494B-A5DD-A5BAE3BB19DD';

CREATE TABLE products_tx as
Select id, product_id from(
		SELECT id,SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 1), ',', -1) as  product_id
		from transactions t 
		UNION 
		SELECT id,IF(LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 2, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1),0) as  product_id
		from transactions t 
		UNION 
		SELECT id,IF(LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 3, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1),0) as  product_id
		from transactions t 
		UNION 
		SELECT id,IF(LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 4, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1),0) as  product_id
		from transactions t 
		UNION 
		SELECT id,IF(LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 5, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 5), ',', -1),0) as  product_id
		from transactions t 
		UNION 
		SELECT id,IF(LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 6, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 6), ',', -1),0) as  product_id
		from transactions t ) p
WHERE product_id <>0
order by id, product_id
;

select * from products_tx;


