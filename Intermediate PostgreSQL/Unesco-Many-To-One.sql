/*
In this assignment you will read some Unesco Heritage Site data in comma-separated-values (CSV) 
format and produce properly normalized tables as specified below.

Normalize the data in the unesco_raw table by adding the entries to each of the lookup tables (category, etc.) and then adding the foreign key columns to the unesco_raw table. Then make a new table called unesco that removes all of the un-normalized redundant text columns like category.
If you run the program multiple times in testing or with different files, make sure to empty out the data before each run.

The autograder will look at the unesco table.
*/

# Download the csv file
wget https://www.pg4e.com/tools/sql/whc-sites-2018-small.csv

# Create the tables reqiured to copy the file in pgsql and carry out the required to normalize the data
CREATE TABLE unesco_raw(
  name TEXT,
  description TEXT,
  justification TEXT,
  year INTEGER,
  longitude FLOAT,
  latitude FLOAT,
  area_hectares FLOAT,
  category TEXT,
  category_id INTEGER,
  state TEXT,
  state_id INTEGER,
  region TEXT,
  region_id INTEGER,
  iso TEXT,
  iso_id INTEGER);

CREATE TABLE unesco(
  name TEXT,
  description TEXT,
  justification TEXT,
  year INTEGER,
  longitude FLOAT,
  latitude FLOAT,
  area_hectares FLOAT,
  category_id INTEGER,
  state_id INTEGER,
  region_id INTEGER,
  iso_id INTEGER);

CREATE TABLE category (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE state(
id SERIAL,
name VARCHAR(128) UNIQUE,
PRIMARY KEY(id)
);

CREATE TABLE iso(
id SERIAL,
name VARCHAR(128) UNIQUE,
PRIMARY KEY(id)
);

CREATE TABLE region(
id SERIAL,
name VARCHAR(128) UNIQUE,
PRIMARY KEY(id)
);

# copy the data from csv file into the unesco_raw tables
/copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso)
FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER

# Insert the category text distinct values into the category table name column
INSERT INTO category(name) SELECT DISTINCT category FROM unesco_raw;

# Insert the state text distinct values into the state table name column
INSERT INTO state(name) SELECT DISTINCT state FROM unesco_raw;

# Insert the iso text distinct values into the iso table name column
INSERT INTO iso(name) SELECT DISTINCT iso FROM unesco_raw;

# Insert the region text distinct values into the region table name column
INSERT INTO region(name) SELECT DISTINCT region FROM unesco_raw;

# Now it is time to insert the foreign keys of the category, state and iso table into the unesco_raw tables
UPDATE unesco_raw SET category_id = (SELECT id FROM category WHERE category.name = unesco_raw.category);
UPDATE unesco_raw SET state_id = (SELECT id FROM state WHERE state.name = unesco_raw.state);
UPDATE unesco_raw SET iso_id = (SELECT id FROM iso WHERE iso.name = unesco_raw.iso);
UPDATE unesco_raw SET region_id = (SELECT id FROM region WHERE region.name = unesco_raw.region);


# Let's move the data to unesco table where we will use the foreign keys for the category, state and iso columns thus normalizing the data copied from csv file
INSERT INTO unesco(name, description, justification, year, longitude, latitude, area_hectares, category_id,
  state_id, region_id, iso_id)
  SELECT name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id,
    region_id, iso_id FROM unesco_raw;

# Let's check if the unesco table can be put together with helt of join command
SELECT unesco.name, year, category.name, state.name, region.name, iso.name
  FROM unesco
  JOIN category ON unesco.category_id = category.id
  JOIN iso ON unesco.iso_id = iso.id
  JOIN state ON unesco.state_id = state.id
  JOIN region ON unesco.region_id = region.id
  ORDER BY category.name, unesco.name
  LIMIT 3;

# Everything works, time to drop the unesco_raw table to clear the memory
DROP TABLE unesco_raw;
