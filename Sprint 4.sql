-- ****************** Nivell 1 **************************

-- Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
-- usuaris
    -- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS vendes;
    USE vendes;

    -- Creamos la tabla credit_cards
	DROP TABLE transactions;
    DROP TABLE companies;
    DROP TABLE credit_cards;
	DROP TABLE european_users;       
    CREATE TABLE IF NOT EXISTS european_users (
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
    );-- id	name	surname	phone	email	birth_date	country	city	postal_code	address
   
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
	-- FOREIGN KEY (user_id) 		REFERENCES european_users(id)  
);-- id	user_id	iban	pan	pin	cvv	track1	track2	expiring_date

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS companies (
        id 		VARCHAR(255) PRIMARY KEY,
        name 	VARCHAR(255),
        phone 	VARCHAR(15),
        email 	VARCHAR(50),
        country VARCHAR(50),
        website VARCHAR(255)
    ); -- company_id	company_name	phone	email	country	website

    
    -- Creamos la tabla transactions
    CREATE TABLE IF NOT EXISTS transactions (
        id 			VARCHAR(255) PRIMARY KEY,
        card_id 	VARCHAR(255), -- REFERENCES credit_card(id),
        business_id VARCHAR(255), -- REFERENCES companies(id),
        date_tx		VARCHAR(25),
		amount 		DECIMAL(10, 2),
        declined 	BOOLEAN,
        product_ids VARCHAR(255) , -- REFERENCES products(id),
		user_id 	VARCHAR(255)  REFERENCES european_users(id),
        lat 		VARCHAR(255),
        longitude 	VARCHAR(255),
        FOREIGN KEY (card_id) 		REFERENCES credit_cards(id),
        FOREIGN KEY (business_id) 	REFERENCES companies(id)
        -- FOREIGN KEY (product_ids) 	REFERENCES products(id),
        -- FOREIGN KEY (user_id) 		REFERENCES european_users(id)        
    );

SHOW VARIABLES LIKE "secure_file_priv";
SELECT @@GLOBAL.secure_file_priv;
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/european_users.csv" INTO TABLE european_users
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

select DATE_FORMAT(NOW(), '%b %d, %Y');
SELECT STR_TO_DATE(NOW(), '%d-%b-%y');
SELECT * from european_users;
SELECT * from transactions;


-- transaccions

-- Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.


-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

-- ****************** Nivell 2 **************************
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:

-- Exercici 1
-- Quantes targetes estan actives?


-- ****************** Nivell 3 **************************
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- Exercici 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.