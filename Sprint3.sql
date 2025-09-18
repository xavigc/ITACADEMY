-- ****************** Nivell 1 **************************
USE transacrions;
-- Exercici 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company").
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
DROP TABLE IF EXISTS credit_card;
CREATE TABLE IF NOT EXISTS credit_card (
	id 				VARCHAR(15) PRIMARY KEY,
	company_id 		VARCHAR(20), 
    transaction_id 	VARCHAR(255),
    iban 			VARCHAR(255),
    pan				VARCHAR(255),
    pin				VARCHAR(4),
    cvv				VARCHAR(3),
    expiring_date	VARCHAR(8),
    FOREIGN KEY (transaction_id) REFERENCES transaction(id) 
);

-- SELECT count(*) from credit_card;
-- Exercici 2
-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938.
-- La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

SELECT id,iban FROM credit_card WHERE id='CcU-2938';-- 'TR301950312213576817638661'
UPDATE credit_card SET iban = 'TR323456312213576817699999' WHERE id='CcU-2938';
SELECT id,iban FROM credit_card WHERE id='CcU-2938';-- 'TR323456312213576817699999'

-- Exercici 3
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:

-- Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
-- credit_card_id	CcU-9999
-- company_id	b-9999
-- user_id	9999
-- lat	829.999
-- longitude	-117.999
-- amount	111.11
-- declined	0

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', timestamp, '111.11', '0');
-- Da error ya que no existe la companyia 'b-9999' y hay una foreig KEY a la tabla de conpany

-- Exercici 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.

DESC credit_card;
ALTER TABLE credit_card DROP column pan;
DESC credit_card;

-- ****************** Nivell 2 **************************
-- Exercici 1
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.
SELECT * FROM  transaction WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
DELETE FROM transaction WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
SELECT * FROM  transaction WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
-- Exercici 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia.
--  Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
CREATE OR REPLACE VIEW VistaMarketing AS (
											SELECT company_name, phone, country, AVG(amount) AS mitjana_compra
											FROM company c, transaction t
											WHERE c.id = t.company_id
											GROUP BY company_name, phone, country
											ORDER BY AVG(amount) DESC
										  );

SELECT * FROM VistaMarketing ORDER BY mitjana_compra DESC;

-- Exercici 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

SELECT * FROM VistaMarketing WHERE country = "Germany";

-- ****************** Nivell 3 **************************

-- Exercici 1
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

-- En aquesta activitat, és necessari que descriguis el "pas a pas" de les tasques realitzades. És important realitzar descripcions senzilles, simples i fàcils de comprendre. Per a realitzar aquesta activitat hauràs de treballar amb els arxius denominats "estructura_dades_user" i "dades_introduir_user"
-- Recorda continuar treballant sobre el model i les taules amb les quals ja has treballat fins ara.

ALTER TABLE credit_card 
ADD fecha_actual DATE DEFAULT (CURRENT_DATE);

DESC user;
ALTER TABLE user
RENAME COLUMN email TO personal_email;

DESC transaction; 
ALTER TABLE transaction
MODIFY COLUMN user_id CHAR(10);
ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES user(id) ;

 
-- Exercici 2
-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:

CREATE OR REPLACE VIEW InformeTecnico AS(
										SELECT t.id, name, surname, iban, company_name
                                        FROM transaction t
                                        INNER JOIN user u ON u.id = user_id 
                                        INNER JOIN credit_card cc ON cc.id = credit_card_id 
                                        INNER JOIN company c ON c.id = t.company_id
                                        );
SELECT * FROM InformeTecnico ORDER BY id DESC; 
