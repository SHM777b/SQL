/*
This application will read an iTunes library in comma-separated-values (CSV) and 
produce properly normalized tables as specified below.

We will do some things differently in this assignment. We will not use a separate
"raw" table, we will just use ALTER TABLE statements to remove columns after we 
don't need them (i.e. we converted them into foreign keys).

We will use the same CSV track data as in prior exercises - this time we will 
build a many-to-many relationship using a junction/through/join table between 
tracks and artists.
*/

# Let's start with creating the necessary tables
DROP TABLE album CASCADE;
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE track CASCADE;
CREATE TABLE track (
    id SERIAL,
    title TEXT, 
    artist TEXT, 
    album TEXT, 
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER,
    PRIMARY KEY(id)
);

DROP TABLE artist CASCADE;
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE tracktoartist CASCADE;
CREATE TABLE tracktoartist (
    id SERIAL,
    track VARCHAR(128),
    track_id INTEGER REFERENCES track(id) ON DELETE CASCADE,
    artist VARCHAR(128),
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);

# copy the data from csv file into the track table
\copy track(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

# Insert the album text distinct values from track table into the album table title column.
INSERT INTO album (title) SELECT DISTINCT album FROM track;

# Insert the foreign keys for the albums from album table into the track table.
UPDATE track SET album_id = (SELECT album.id FROM album WHERE album.title = track.album);

# Insert the artist text distinct values from track table into the artist table name column.
INSERT INTO artist (name) SELECT DISTINCT artist FROM track;

# Insert DISTINCT combination of artist and track from track table into tracktoartist table track and artist columns.
INSERT INTO tracktoartist (track, artist) SELECT DISTINCT title, artist FROM track;

# Update the tracktoartist table with foreign key references from track and artist tables.
UPDATE tracktoartist SET track_id = (SELECT track.id FROM track WHERE track.title = tracktoartist.track);
UPDATE tracktoartist SET artist_id = (SELECT artist.id FROM artist WHERE artist.name = tracktoartist.artist);

# Drop the txt columns that have been normalized to empty the memory
ALTER TABLE track DROP COLUMN album;
ALTER TABLE track DROP COLUMN track;
ALTER TABLE tracktoartist DROP COLUMN track;
ALTER TABLE tracktoartist DROP COLUMN artist;

# Check if the JOIN table produces the required outcome.
SELECT track.title, album.title, artist.name
FROM track
JOIN album ON track.album_id = album.id
JOIN tracktoartist ON track.id = tracktoartist.track_id
JOIN artist ON tracktoartist.artist_id = artist.id
LIMIT 3;
