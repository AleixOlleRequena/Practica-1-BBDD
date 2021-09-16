set lc_monetary to "en_US";

-- price
UPDATE property SET price = trim(price, '$');
UPDATE property SET price = replace(price, ',', '');
ALTER TABLE property ALTER COLUMN price TYPE REAL USING price::REAL;


-- weekly_price
UPDATE property SET weekly_price = trim(weekly_price, '$');
UPDATE property SET weekly_price = replace(weekly_price, ',', '');
ALTER TABLE property ALTER COLUMN weekly_price TYPE REAL USING weekly_price::REAL;
UPDATE property SET weekly_price = (price*7) WHERE weekly_price IS NULL;
UPDATE property SET weekly_price = (price*7) WHERE weekly_price = 0;
UPDATE property SET price = (weekly_price/7) WHERE price >= weekly_price;


-- monthly_price
UPDATE property SET monthly_price = trim(monthly_price, '$');
UPDATE property SET monthly_price = replace(monthly_price, ',', '');
ALTER TABLE property ALTER COLUMN monthly_price TYPE REAL USING monthly_price::REAL;
UPDATE property SET monthly_price = (price*30) WHERE monthly_price IS NULL;


-- security_deposit
UPDATE property SET security_deposit = trim(security_deposit, '$');
UPDATE property SET security_deposit = replace(security_deposit, ',', '');
ALTER TABLE property ALTER COLUMN security_deposit TYPE REAL USING security_deposit::REAL;
UPDATE property SET security_deposit = 0 WHERE security_deposit IS NULL;


-- cleaning_fee
UPDATE property SET cleaning_fee = trim(cleaning_fee, '$');
UPDATE property SET cleaning_fee = replace(cleaning_fee, ',', '');
ALTER TABLE property ALTER COLUMN cleaning_fee TYPE REAL USING cleaning_fee::REAL;
UPDATE property SET cleaning_fee = 0 WHERE cleaning_fee IS NULL;



UPDATE host SET host_response_rate = trim(host_response_rate, '%');

UPDATE host SET host_response_rate = NULL WHERE host_response_rate = 'N/A';
ALTER TABLE host ALTER COLUMN host_response_rate TYPE REAL USING host_response_rate::REAL;

ALTER TABLE host ALTER COLUMN host_since TYPE date USING host_since::date;

UPDATE importapartments SET price = trim(price, '$');
UPDATE importapartments SET price = replace(price, ',', '');
ALTER TABLE importapartments ALTER COLUMN price TYPE REAL USING price::REAL;

UPDATE importapartments SET weekly_price = trim(weekly_price, '$');
UPDATE importapartments SET weekly_price = replace(weekly_price, ',', '');
ALTER TABLE importapartments ALTER COLUMN weekly_price TYPE REAL USING weekly_price::REAL;

UPDATE importapartments SET cleaning_fee = trim(cleaning_fee, '$');
UPDATE importapartments SET cleaning_fee = replace(cleaning_fee, ',', '');
ALTER TABLE importapartments ALTER COLUMN cleaning_fee TYPE REAL USING cleaning_fee::REAL;

UPDATE importapartments SET security_deposit = trim(security_deposit, '$');
UPDATE importapartments SET security_deposit = replace(security_deposit, ',', '');
ALTER TABLE importapartments ALTER COLUMN security_deposit TYPE REAL USING security_deposit::REAL;

UPDATE importapartments SET weekly_price = (price*7) WHERE weekly_price IS NULL;
UPDATE importapartments SET weekly_price = (price*7) WHERE weekly_price = 0;
UPDATE importapartments SET price = (weekly_price/7) WHERE price >= weekly_price;
UPDATE importapartments SET cleaning_fee = 0 WHERE cleaning_fee IS NULL;
UPDATE importapartments SET security_deposit = 0 WHERE security_deposit IS NULL;

UPDATE importhosts SET host_response_rate = trim(host_response_rate, '%');

UPDATE importhosts SET host_response_rate = NULL WHERE host_response_rate = 'N/A';
ALTER TABLE importhosts ALTER COLUMN host_response_rate TYPE REAL USING host_response_rate::REAL;
ALTER TABLE importhosts ALTER COLUMN host_since TYPE date USING host_since::date;















--COMENCEM LES QUERIES


-- FIRST QUERY
SELECT name_city AS name, ((avg(price*7) - avg(weekly_price)) / avg(price*7)) * 100 AS saving_percentage
FROM city, property, host WHERE city.id_city = property.id_city AND host.id_host = property.id_host
AND host_identity_verified IS TRUE AND price > 0 AND min_nights < 7 AND max_nights >= 7 AND price*7 > weekly_price
GROUP BY city.id_city
ORDER BY saving_percentage DESC LIMIT 3;

-- COMPROVACIO FIRST QUERY
SELECT city AS name, ((avg(price*7) - avg(weekly_price)) / avg(price*7)) * 100 AS saving_percentage
FROM importapartments, importhosts WHERE importhosts.listing_url = importapartments.listing_url
AND host_identity_verified IS TRUE AND price > 0 AND minimum_nights < 7 AND maximum_nights >= 7 AND price*7 > weekly_price
GROUP BY city
ORDER BY saving_percentage DESC LIMIT 3;



-- SECOND QUERY
SELECT name_property, round((price/squarefeet)::numeric,2):: money AS price_m2, count(reviewercommentproperty.id_property) AS reviews
FROM property, reviewercommentproperty
WHERE property.id_property = reviewercommentproperty.id_property AND squarefeet IS NOT NULL AND squarefeet > 0
AND property_type = 'Guesthouse'
GROUP BY name_property, (price/squarefeet)
HAVING count(id_reviewercomment) >=200
ORDER BY price_m2 DESC LIMIT 1;

--COMPROVACIÓ SECOND QUERY
SELECT importapartments.name, round((price/square_feet)::numeric,2):: money AS price_m2, count(importreviews.listing_url) AS reviews
FROM importapartments, importreviews
WHERE importreviews.listing_url = importapartments.listing_url AND square_feet IS NOT NULL AND square_feet > 0
AND property_type = 'Guesthouse'
GROUP BY importapartments.name, round((price/square_feet)::numeric,2):: money
HAVING count(importreviews.listing_url) >=200
ORDER BY price_m2 DESC LIMIT 1;



-- THIRD QUERY
SELECT name_property AS name, listing_url AS url, ((((price*5)*6) + cleaning_fee) + (security_deposit*0.1))::numeric:: money AS price  FROM property, neighbourhood, hasamenity, amenity, host
WHERE property.id_property = hasamenity.id_property AND property.id_neighbourhood = neighbourhood.id_neighbourhood AND host.id_host = property.id_host
AND amenity.id_amenity = hasamenity.id_amenity
AND max_residents = 6 AND name_amenity = 'Balcony' AND bathrooms > 1.5 AND host_response_rate > 90 AND name_neighbourhood = 'Port Phillip'
ORDER BY price ASC LIMIT 1;

--COMPROVACIÓ THIRD QUERY
SELECT importapartments.name AS name, importapartments.listing_url AS url, ((((price*5)*6) + cleaning_fee) + (security_deposit*0.1):: numeric) AS price  FROM importapartments, importhosts
WHERE importhosts.listing_url = importapartments.listing_url
AND accommodates = 6 AND amenities ILIKE '%,Balcony%' AND bathrooms > 1.5 AND host_response_rate > 90 AND neighbourhood_cleansed = 'Port Phillip'
ORDER BY price ASC LIMIT 1;



-- FOURTH QUERY
UPDATE host SET host_is_superhost = TRUE WHERE host_since <= '2014-12-31';
UPDATE host SET host_is_superhost = FALSE WHERE host_since > '2014-12-31';
SELECT count(id_host) AS superhost FROM host WHERE host_is_superhost = TRUE;
SELECT count(id_host) AS normal_hosts FROM host WHERE host_is_superhost = FALSE;

--COMPROVACIÓ FOURTH QUERY
UPDATE importhosts SET host_is_superhost = TRUE WHERE host_since <= '2014-12-31';
UPDATE importhosts SET host_is_superhost = FALSE WHERE host_since > '2014-12-31';
SELECT count(id_host) AS superhost FROM host WHERE host_is_superhost = TRUE;
SELECT count(id_host) AS normal_hosts FROM host WHERE host_is_superhost = FALSE;



-- FIFTH QUERY
SELECT name_street AS street, COUNT(street.id_street) AS num, round(avg(price)::numeric,2)::money AS price FROM street, property
WHERE street.id_street = property.id_street
GROUP BY  street.id_street
HAVING AVG(price) < 100
ORDER BY num DESC LIMIT 3;

-- COMPROVACIÓ FIFTH QUERY
SELECT street AS street, COUNT(listing_url) AS num, round(avg(price)::numeric,2)::money AS price FROM importapartments
GROUP BY street
HAVING AVG(price) < 100
ORDER BY num DESC LIMIT 3;



-- SIXTH QUERY
SELECT  name_reviewer, listing_url AS url, COUNT(id_reviewercomment) AS num_reviews FROM reviewercommentproperty, reviewer, property
WHERE reviewercommentproperty.id_reviewer = reviewer.id_reviewer AND property.id_property = reviewercommentproperty.id_property
GROUP BY  reviewer.id_reviewer, name_reviewer, listing_url
ORDER BY num_reviews DESC, name_reviewer DESC LIMIT 3;
-- El Cameron està fent reviews falses, per tant no l'hem de tenir en compte en futures queries.

-- COMPROVACIÓ SIXTH QUERY
SELECT  reviewer_name, importreviews.listing_url AS url, COUNT(importreviews.listing_url) AS num_reviews FROM importapartments,importreviews
WHERE importapartments.listing_url = importreviews.listing_url
GROUP BY  reviewer_name,importreviews.listing_url, reviewer_id
ORDER BY num_reviews DESC, reviewer_name DESC LIMIT 3;



-- EIGHTH QUERY
SELECT property.id_property AS id, name_property AS name,  (((price*2*2) + cleaning_fee) + (security_deposit*0.1))::numeric:: money AS total_price FROM city,property, amenity, hasamenity, host, verification, verifies
WHERE host.id_host = property.id_host AND city.id_city = property.id_city AND amenity.id_amenity = hasamenity.id_amenity
AND property.id_property = hasamenity.id_property AND verifies.id_verification = verification.id_verification
AND host.id_host = verifies.id_host
AND max_residents >= 2 AND beds >= 2 AND name_city = 'Saint Kilda' And name_amenity = 'Kitchen' AND name_verification = 'phone'
AND (((price*2*2) + cleaning_fee) + (security_deposit*0.1)) < 5000 AND min_nights <= 2
GROUP BY property.id_property
ORDER BY total_price DESC;

-- COMPROVACIO SEVENTH QUERY, EL ID DEL RESULTAT ÉS DIFERENT PERQUÈ NOSALTRES VAM CREAR EL NOSTRE ID FENT SERVIR EL SERIAL
SELECT id AS id, importapartments.name AS name,  (((price*2*2) + cleaning_fee) + (security_deposit*0.1))::numeric:: money AS total_price FROM importapartments, importhosts
WHERE importhosts.listing_url = importapartments.listing_url
AND accommodates >= 2 AND beds >= 2 AND city = 'Saint Kilda' And amenities ILIKE '%Kitchen%' AND host_verifications ILIKE '%phone%'
AND (((price*2*2) + cleaning_fee) + (security_deposit*0.1)) < 5000 AND minimum_nights <= 2
GROUP BY id, importapartments.name, (((price*2*2) + cleaning_fee) + (security_deposit*0.1))::numeric:: money
ORDER BY total_price DESC;



-- EIGTH QUERY
-- Creem taules intermitges per guardar la quantitat de verificacions i la d'apartamens, després les utilitzarem en la recerca
DROP TABLE IF EXISTS numeroVerifications;
CREATE TABLE numeroVerifications(
    id_host INT,
    numeroVerifications int
);

DROP TABLE IF EXISTS numeroApartments;
CREATE TABLE numeroApartments(
    id_host INT,
    numeroApartments int
);

INSERT INTO numeroVerifications SELECT host.id_host, count(verifies.id_verification) FROM host , verifies , verification
WHERE verifies.id_host = host.id_host AND verification.id_verification = verifies.id_verification GROUP BY host.id_host;

INSERT INTO numeroApartments SELECT host.id_host, count(property.id_host) FROM host , property
WHERE host.id_host = property.id_host GROUP BY host.id_host;

-- Fem la recerca final
SELECT name_host AS name, SUM((1/price)*(1 + host_is_superhost:: INT)*(SELECT numeroVerifications.numeroVerifications
FROM numeroVerifications WHERE numeroVerifications.id_host = h2.id_host )*
(SELECT numeroApartments.numeroApartments FROM numeroApartments WHERE numeroApartments.id_host = h2.id_host)) AS score, count(h2.id_host) -- Aquí s'acaba el select
FROM host AS h2, property AS p2 WHERE h2.id_host = p2.id_host AND price > 0  AND name_host IS NOT NULL
GROUP BY h2.id_host
ORDER BY score DESC LIMIT 3;


-- COMPROVACIÓ EIGHTH QUERY
/* PER AQUESTA COMPROVACIÓ HE HAGUT DE CREAR UNA TAULA INTERMITJA PER TAL DE PODER CONTAR LES VERIFICACIONS
   DE CADA HOST, UN COP TENIEM A LA TAULA UNA FILA PER CADA VERIFICACIÓ DEL HOST HO PASSEM A UNA ALTRA FENT UN COUNT I AIXÍ OBTENIM
   QUANTES VERIFICACIONS TÉ CADA HOST
   */
DROP TABLE IF EXISTS VerificationsComprovacioIntermig;
CREATE TABLE VerificationsComprovacioIntermig(
    id_host INT,
    verificacio VARCHAR(50)
);

INSERT INTO VerificationsComprovacioIntermig SELECT DISTINCT host_id, regexp_split_to_table(host_verifications, ',') FROM importhosts;

DROP TABLE IF EXISTS numeroApartmentsComprovacio;
CREATE TABLE numeroApartmentsComprovacio(
    id_host INT,
    numeroApartments int
);

INSERT INTO numeroApartmentsComprovacio SELECT host_id, COUNT(host_id) FROM importhosts GROUP BY host_id;


DROP TABLE IF EXISTS VerificationsComprovacio;
CREATE TABLE VerificationsComprovacio(
    id_host INT,
    verificacio INT
);

INSERT INTO VerificationsComprovacio SELECT id_host, COUNT(id_host) FROM VerificationsComprovacioIntermig GROUP BY id_host;

DROP TABLE IF EXISTS VerificationsComprovacioIntermig;


SELECT host_name AS name, SUM((1/price)*(1 + host_is_superhost:: INT)*(SELECT VerificationsComprovacio.verificacio
FROM VerificationsComprovacio WHERE VerificationsComprovacio.id_host = h2.host_id )*
(SELECT numeroApartmentsComprovacio.numeroApartments FROM numeroApartmentsComprovacio WHERE numeroApartmentsComprovacio.id_host = h2.host_id)) AS score -- Aquí s'acaba el select
FROM importhosts AS h2, importapartments AS p2 WHERE h2.listing_url = p2.listing_url AND price > 0  AND host_name IS NOT NULL
GROUP BY h2.host_id, h2.host_name
ORDER BY score DESC LIMIT 3;


-- NINTH QUERY
DROP TABLE IF EXISTS PointComments;
CREATE TABLE PointComments(
    name_reviewer VARCHAR(255),
    id_reviewer INT,
    points int
);

-- Inserim els punts dels usuaris per comentaris més llargs de 100 caràcters, NO agafem el id_reviewer = 49929207 perquè és l'usuari que ha escrit reviews falses
INSERT INTO PointComments
SELECT name_reviewer,reviewer.id_reviewer, count(reviewer.id_reviewer)*15
FROM reviewer, reviewercommentproperty
WHERE reviewer.id_reviewer = reviewercommentproperty.id_reviewer AND length(comment) >= 100 AND reviewer.id_reviewer != 49929207
GROUP BY reviewer.id_reviewer;

-- Inserim els punts dels usuaris per comentaris més curts de 100 caràcters
INSERT INTO PointComments
SELECT name_reviewer, reviewer.id_reviewer, count(reviewer.id_reviewer)*10
FROM reviewer, reviewercommentproperty
WHERE reviewer.id_reviewer = reviewercommentproperty.id_reviewer AND length(comment) < 100 AND reviewer.id_reviewer != 49929207
GROUP BY reviewer.id_reviewer;

-- select final
SELECT name_reviewer AS name, SUM(PointComments.points) AS points
FROM  PointComments
GROUP BY name_reviewer, PointComments.id_reviewer
ORDER BY points DESC LIMIT 10;


-- COMPROVACIÓ NOVENA QUERY
DROP TABLE IF EXISTS PointCommentsComprovacio;
CREATE TABLE PointCommentsComprovacio(
    name_reviewer VARCHAR(255),
    id_reviewer INT,
    points int
);

-- Inserim els punts dels usuaris per comentaris més llargs de 100 caràcters, NO agafem el id_reviewer = 49929207 perquè és l'usuari que ha escrit reviews falses
INSERT INTO PointCommentsComprovacio
SELECT reviewer_name, reviewer_id, count(reviewer_id)*15
FROM importreviews
WHERE length(comments) >= 100 AND reviewer_id != 49929207
GROUP BY reviewer_id, reviewer_name;

-- Inserim els punts dels usuaris per comentaris més curts de 100 caràcters
INSERT INTO PointCommentsComprovacio
SELECT reviewer_name,reviewer_id, count(reviewer_id)*10
FROM importreviews
WHERE length(comments) < 100 AND reviewer_id != 49929207
GROUP BY reviewer_id, reviewer_name;

-- SELECT FINAL
SELECT name_reviewer AS name, SUM(PointCommentsComprovacio.points) AS points
FROM  PointCommentsComprovacio
GROUP BY name_reviewer, PointCommentsComprovacio.id_reviewer
ORDER BY points DESC LIMIT 10;



-- DESENA QUERY
-- PER FER LA NOSTRA QUERY HEM TRIAT MOSTRAR TOTES LES CIUTATS ACOMPANYADES DE LA QUANTITAT D'APARTAMENTS I EL PREU MIG D'AQUESTS. D'AQUESTA FORMA
-- ELS USUARIS PODRAN VEURE EN QUINA CIUTAT TENEN UNA OFERTA D'APARTAMENTS MÉS GRAN AMB UN PREU MIG QUE S'AJUSTI MÉS AL SEU PREESSUPOST.
-- ELS USUARIS PODRAN TRIAR SI ANAR A UNA CIUTAT ON LA OFERTA ÉS MOLT GRAN PERÒ EL PREU ÉS MOLT ALT O ANAR A UN LLOC AMB POCA OFERTA PERÒ PREUS MÉS AJUSTATS

SELECT name_city, count(city.id_city) AS num_apartments, AVG(price)::numeric::money AS preu_mig FROM city, property WHERE city.id_city = property.id_city
GROUP BY city.id_city ORDER BY num_apartments DESC, preu_mig ASC;

--COMPROVACIÓ DESENA QUERY
SELECT city, count(city) AS num_apartments, AVG(price)::numeric::money AS preu_mig FROM importapartments
GROUP BY city ORDER BY num_apartments DESC, preu_mig ASC;





