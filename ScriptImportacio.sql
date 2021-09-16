-- We import the data from .csv files
COPY ImportApartments FROM  'D:\LASALLE\Bases de dades\1920\Practica\apartments.csv' CSV HEADER DELIMITER ',';
COPY ImportHosts FROM  'D:\LASALLE\Bases de dades\1920\Practica\hosts.csv' CSV HEADER DELIMITER ',';
COPY ImportReviews FROM  'D:\LASALLE\Bases de dades\1920\Practica\review.csv' CSV HEADER DELIMITER ',';


-- We remove the NULL from teh state field in importaApartments table
UPDATE ImportApartments SET state = '' WHERE state IS NULL;

-- We clean and correct the data provided so that the final tables are correct
UPDATE ImportApartments SET state = 'VIC' WHERE state LIKE 'Vic%' OR state LIKE 'vic%' OR state LIKE 'VI%' OR state LIKE '%VI%' OR state LIKE 'Mel%' OR state LIKE 'Australia' OR state = '' OR state = '维多利亚州' OR state = '维多利亚';

UPDATE ImportApartments SET city = trim(city);

UPDATE ImportApartments SET city = neighbourhood_cleansed WHERE city = '';

UPDATE ImportApartments SET street = ltrim(street);

UPDATE ImportApartments SET street = replace(street, ' ,', ',');

UPDATE ImportApartments SET city = replace(city, ', Melbourne', '');
UPDATE ImportApartments SET city = replace(city, '，Melbourne', '');
UPDATE ImportApartments SET city = replace(city, ' / Melbourne', '');
UPDATE ImportApartments SET city = replace(city, '. Melbourne', '');
UPDATE ImportApartments SET city = replace(city, 'St Kilda West Melbourne', 'St Kilda West');
UPDATE ImportApartments SET city = replace(city, 'Park Melbourne', 'Park');
UPDATE ImportApartments SET city = replace(city, '墨爾本 Melbourne', 'Melbourne');
UPDATE ImportApartments SET city = replace(city, 'Southbank, Victoria, AU', 'Southbank');
UPDATE ImportApartments SET city = replace(city, 'Southbank Melbourne', 'Southbank');
UPDATE ImportApartments SET city = replace(city, 'West Melbourne - flagstaff', 'West Melbourne');
UPDATE ImportApartments SET city = replace(city, '芒特韦弗利区', 'Mount Waverley');
UPDATE ImportApartments SET city = replace(city, '墨尔本', 'Melbourne');
UPDATE ImportApartments SET city = replace(city, ', Victoria, AU', '');
UPDATE ImportApartments SET city = replace(city, ', St. Kilda', '');
UPDATE ImportApartments SET city = replace(city, ', Yarra Valley', '');
UPDATE ImportApartments SET city = replace(city, 'Yarra Valley, Yarra Glen, Healesville', 'Healesville');
UPDATE ImportApartments SET city = replace(city, 'Wesburn,10minutes to Warburton', 'Wesburn');
UPDATE ImportApartments SET city = replace(city, 'VIC 3150', '');
UPDATE ImportApartments SET city = replace(city, 'VIC 3152', '');
UPDATE ImportApartments SET city = replace(city, 'VIC 3141', '');
UPDATE ImportApartments SET city = replace(city, 'VIC 3108', '');
UPDATE ImportApartments SET city = replace(city, 'VIC 3056', '');
UPDATE ImportApartments SET city = replace(city, 'VIC 3062', '');
UPDATE ImportApartments SET city = replace(city, 'VIC', 'Melbourne');
UPDATE ImportApartments SET city = replace(city, 'St Kilda', 'St. Kilda');
UPDATE ImportApartments SET city = replace(city, 'St.Kilda', 'St. Kilda');
UPDATE ImportApartments SET city = replace(city, 'Strthtulloch', 'Strathtulloh');
UPDATE ImportApartments SET city = neighbourhood_cleansed WHERE city = 'Victoria';
UPDATE ImportApartments SET city = replace(city, 'Ivanhoe (Melbourne)', 'Ivanhoe');
UPDATE ImportApartments SET city = initcap(city);
UPDATE ImportApartments SET city = 'Melbourne' WHERE city LIKE 'melb%' OR city LIKE 'Melb%' OR city LIKE 'Mleb%';

UPDATE ImportApartments SET city =  regexp_replace(city, '\s+$', '') || '' ;

UPDATE ImportHosts SET host_verifications = 'None' WHERE host_verifications = '' OR host_verifications = '[]';


--We import the data to our project tables.
-- We import the countries and their codes
INSERT INTO Country SELECT DISTINCT country_code, country FROM ImportApartments;

-- We import the states.
INSERT INTO State(name_state)  SELECT DISTINCT state FROM ImportApartments;

-- We import the cities.
INSERT INTO City(name_city)  SELECT DISTINCT city FROM ImportApartments;

-- We import the neighbourhood.
INSERT INTO Neighbourhood(name_neighbourhood) SELECT DISTINCT neighbourhood_cleansed FROM ImportApartments;

-- We import the streets.
 INSERT INTO Street (name_street) SELECT DISTINCT street FROM  ImportApartments ;

-- We insert the differents hosts from ImportHosts.
INSERT INTO Host(id_host, name_host, host_url, host_since, host_about, host_response_time, host_response_rate, host_is_superhost, host_picture_url, host_listings, host_identity_verified)
 SELECT DISTINCT host_id, host_name, host_url, host_since, host_about, host_response_time, host_response_rate, host_is_superhost, host_picture_url, host_listings_count, host_identity_verified FROM ImportHosts;

-- We insert the differents properties.
INSERT INTO Property(listing_url, name_property, description, picture_url, zipcode, property_type, max_residents, bathrooms, bedrooms, beds, squarefeet, price, weekly_price, monthly_price, security_deposit, cleaning_fee, min_nights, max_nights ,id_host, country_code, id_state, id_city, id_neighbourhood, id_street)
SELECT DISTINCT ImportApartments.listing_url, ImportApartments.name, ImportApartments.description, ImportApartments.picture_url, zipcode, property_type, accommodates, bathrooms, bedrooms, beds, square_feet, price, weekly_price, monthly_price, security_deposit, cleaning_fee, minimum_nights, maximum_nights, host_id, ImportApartments.country_code,State.id_state, City.id_city, Neighbourhood.id_neighbourhood, id_street
FROM ImportApartments, ImportHosts, state, city, Neighbourhood, street WHERE ImportHosts.listing_url = ImportApartments.listing_url  AND (ImportApartments.state = name_state AND ImportApartments.city = name_city AND neighbourhood_cleansed = name_neighbourhood AND name_street = ImportApartments.street) ORDER BY listing_url ASC;


-- We insert verifications using the regexp_split_to_table() function to separate the string in each verification and the trim and replace functions to remove unwanted characters.

DROP TABLE IF EXISTS VerificationIntermig;
CREATE TABLE VerificationIntermig(
    name_verification VARCHAR(255)
);
INSERT INTO VerificationIntermig SELECT regexp_split_to_table(host_verifications, ',') FROM ImportHosts;


UPDATE VerificationIntermig SET name_verification = replace(name_verification, '''', '');
UPDATE VerificationIntermig SET name_verification = ltrim(name_verification,'[');
UPDATE VerificationIntermig SET name_verification = rtrim(name_verification,']');
UPDATE VerificationIntermig SET name_verification = trim(name_verification);

-- We insert the updated information into Verification table
INSERT INTO Verification(name_verification) SELECT DISTINCT * FROM VerificationIntermig;

DROP TABLE IF EXISTS VerificationIntermig;


-- We create the relational table between verifications and hosts.

INSERT INTO Verifies SELECT DISTINCT id_verification, id_host FROM Verification, Host, ImportHosts WHERE host_id = id_host AND position(name_verification IN host_verifications) != 0 ;

-- We insert the different apartment amenities 
-- We insert the amenities using the regexp_split_to_table() function to separate the string in each verification and the trim and replace functions to remove unwanted characters.

DROP TABLE IF EXISTS AmenityIntermig;
CREATE TABLE AmenityIntermig(
    name_Amenity VARCHAR(255)
);

INSERT INTO AmenityIntermig SELECT regexp_split_to_table(amenities, ',') FROM ImportApartments;
UPDATE AmenityIntermig SET name_Amenity = replace(name_Amenity, '"', '');
UPDATE AmenityIntermig SET name_Amenity = ltrim(name_Amenity,'{') ;
UPDATE AmenityIntermig SET name_Amenity = rtrim(name_Amenity,'}');
UPDATE AmenityIntermig SET name_Amenity = trim(name_Amenity);

-- We insert the data obtained into the Amenity table.

INSERT INTO Amenity(name_amenity) SELECT DISTINCT * FROM AmenityIntermig;

-- We remove the amenity which is a blank space.

UPDATE Amenity SET name_amenity = 'No té amenities' WHERE name_amenity = '';

DROP TABLE IF EXISTS AmenityIntermig;


-- We create the relational table between amenities and apartments.

INSERT INTO HasAmenity SELECT DISTINCT id_property, id_amenity FROM Amenity, Property, ImportApartments WHERE Property.listing_url = ImportApartments.listing_url AND position(name_amenity IN amenities) != 0 ;

-- We insert the name and ID of the users who have made a review.

INSERT INTO Reviewer SELECT DISTINCT reviewer_id, reviewer_name FROM ImportReviews;

-- Omplim la taula de relacions entre els usuaris que han fet les reviews i els apartaments que han visitat
We create the relational table between Reviewers and the apartments they have stood in.

INSERT INTO ReviewerCommentProperty(id_property, id_reviewer, date_review, comment)  SELECT id_property, reviewer_id, date_review, comments FROM ImportReviews, Property WHERE ImportReviews.listing_url = Property.listing_url;




