--importation tables

DROP TABLE IF EXISTS ImportApartments CASCADE;
CREATE TABLE ImportApartments(
    id INT,
    listing_url VARCHAR(255),
    name VARCHAR(255),
    description TEXT,
    picture_url VARCHAR(255),
    street VARCHAR(255),
    neighbourhood_cleansed VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    zipcode VARCHAR(255),
    country_code VARCHAR(255),
    country VARCHAR(255),
    property_type VARCHAR(255),
    accommodates INT,
    bathrooms FLOAT,
    bedrooms INT,
    beds INT,
    amenities TEXT,
    square_feet FLOAT,
    price VARCHAR(255),
    weekly_price VARCHAR(255),
    monthly_price VARCHAR(255),
    security_deposit VARCHAR(255),
    cleaning_fee VARCHAR(255),
    minimum_nights INT,
    maximum_nights INT
);

DROP TABLE IF EXISTS ImportHosts CASCADE;
CREATE TABLE ImportHosts(
    listing_url VARCHAR(255),
    name VARCHAR(255),
    description TEXT,
    picture_url VARCHAR(255),
    host_id int,
    host_url VARCHAR(255),
    host_name VARCHAR(255),
    host_since VARCHAR(255),
    host_about TEXT,
    host_response_time VARCHAR(255),
    host_response_rate VARCHAR(255),
    host_is_superhost BOOLEAN,
    host_picture_url VARCHAR(255),
    host_listings_count INT,
    host_verifications VARCHAR(255),
    host_identity_verified BOOLEAN
);

DROP TABLE IF EXISTS ImportReviews CASCADE;
CREATE TABLE ImportReviews(
    id INT,
    listing_url VARCHAR(255),
    name VARCHAR(255),
    description TEXT,
    picture_url VARCHAR(255),
    street VARCHAR(255),
    neighbourhood_cleansed VARCHAR(255),
    city VARCHAR(255),
    date_review VARCHAR(255),
    reviewer_id INT,
    reviewer_name VARCHAR(255),
    comments TEXT
);

--We create the project tables.

DROP TABLE IF EXISTS Country CASCADE;
CREATE TABLE Country(
    country_code VARCHAR(20),
    country_name VARCHAR(255),
    PRIMARY KEY(country_code)
);

DROP TABLE IF EXISTS State CASCADE;
CREATE TABLE State(
    id_state SERIAL,
    name_state VARCHAR(255) DEFAULT '',
    PRIMARY KEY(id_state)
);

DROP TABLE IF EXISTS City CASCADE;
CREATE TABLE City(
    id_city SERIAL,
    name_city VARCHAR(255),
    PRIMARY KEY(id_city)
);

DROP TABLE IF EXISTS Neighbourhood CASCADE;
CREATE TABLE Neighbourhood(
    id_neighbourhood SERIAL,
    name_neighbourhood VARCHAR(255),
    PRIMARY KEY(id_neighbourhood)
);

DROP TABLE IF EXISTS street CASCADE ;
CREATE TABLE Street(
    id_street SERIAL,
    name_street VARCHAR(255),
    PRIMARY KEY (id_street)
);


DROP TABLE IF EXISTS Host CASCADE;
CREATE TABLE Host(
    id_host INT,
    name_host VARCHAR(255) ,
    host_url VARCHAR(255),
    host_since VARCHAR(255),
    host_about TEXT,
    host_response_time VARCHAR(255),
    host_response_rate VARCHAR(255),
    host_is_superhost BOOLEAN,
    host_picture_url VARCHAR(255),
    host_listings INT,
    host_identity_verified BOOLEAN,
    PRIMARY KEY (id_host)
);



DROP TABLE IF EXISTS Property CASCADE;
CREATE TABLE Property(
    id_property SERIAL,
    listing_url VARCHAR(255),
    name_property VARCHAR(255),
    description TEXT,
    picture_url VARCHAR(255),
    zipcode VARCHAR(255),
    property_type VARCHAR(255),
    max_residents INT,
    bathrooms FLOAT,
    bedrooms INT,
    beds INT,
    squarefeet FLOAT,
    price VARCHAR(255),
    weekly_price VARCHAR(255),
    monthly_price VARCHAR(255),
    security_deposit VARCHAR(255),
    cleaning_fee VARCHAR(255),
    min_nights INT,
    max_nights INT,
    id_host INT,
    country_code VARCHAR(20),
    id_state INT,
    id_city INT,
    id_neighbourhood INT,
    id_street INT,
    PRIMARY KEY (id_property),
    FOREIGN KEY (id_host) REFERENCES Host(id_host),
    FOREIGN KEY (country_code) REFERENCES Country(country_code),
    FOREIGN KEY (id_state) REFERENCES State(id_state),
    FOREIGN KEY (id_city) REFERENCES City(id_city),
    FOREIGN KEY (id_neighbourhood) REFERENCES Neighbourhood(id_neighbourhood),
    FOREIGN KEY (id_street) REFERENCES street(id_street)
);



DROP TABLE IF EXISTS Verification CASCADE;
CREATE TABLE Verification(
    id_verification SERIAL,
    name_verification VARCHAR(255),
    PRIMARY KEY (id_verification)
);

DROP TABLE IF EXISTS Verifies CASCADE;
CREATE TABLE Verifies(
    id_verification INT,
    id_host INT,
    PRIMARY KEY (id_host,id_verification),
    FOREIGN KEY (id_host) REFERENCES Host(id_host),
    FOREIGN KEY (id_verification) REFERENCES Verification(id_verification)
);

DROP TABLE IF EXISTS Amenity CASCADE;
CREATE TABLE Amenity(
    id_amenity SERIAL,
    name_amenity VARCHAR(255),
    PRIMARY KEY (id_amenity)
);

DROP TABLE IF EXISTS HasAmenity CASCADE;
CREATE TABLE HasAmenity(
    id_property SERIAL,
    id_amenity SERIAL,
    PRIMARY KEY (id_property,id_amenity),
    FOREIGN KEY (id_property) REFERENCES Property(id_property),
    FOREIGN KEY (id_amenity) REFERENCES Amenity(id_amenity)
);

DROP TABLE IF EXISTS Reviewer CASCADE;
CREATE TABLE Reviewer(
    id_reviewer INT,
    name_reviewer VARCHAR(255),
    PRIMARY KEY (id_reviewer)
);

-- In this table we create a different PK because the 2 PK / FK that would belong to this table restrict the insertions, therefore, we take into consideration the notes of the subject and we create the new PK.
DROP TABLE IF EXISTS ReviewerCommentProperty CASCADE;
CREATE TABLE ReviewerCommentProperty(
    id_reviewerComment SERIAL,
    id_property INT,
    id_reviewer INT,
    date_review VARCHAR(255),
    comment TEXT,
    PRIMARY KEY (id_reviewerComment),
    FOREIGN KEY (id_property) REFERENCES Property(id_property),
    FOREIGN KEY (id_reviewer) REFERENCES Reviewer(id_reviewer)
);

