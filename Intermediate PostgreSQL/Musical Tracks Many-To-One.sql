/*
This application will read an iTunes library in comma-separated-values (CSV) 
format and produce properly normalized tables as specified below.

We will ignore the artist field for this assignment and focus on the many-to-one relationship between tracks and albums.
If you run the program multiple times in testing or with different files, make sure to empty out the data before each run.

Load this CSV data file into the track_raw table using the \copy command. 

Then write SQL commands to insert all of the distinct albums into the album 
table (creating their primary keys) and then set the album_id in the track_raw 
table

Then use a INSERT ... SELECT statement to copy the corresponding data from the 
track_raw table to the track table, effectively dropping the artist and album 
text fields.
*/

# Let's start by creating the necessary tables
CREATE TABLE album (
  id SERIAL,
  title VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER, rating INTEGER, count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);

CREATE TABLE track_raw
 (title TEXT, artist TEXT, album TEXT, album_id INTEGER,
  count INTEGER, rating INTEGER, len INTEGER);
  

# Download the csv file using the wget command
wget https://www.pg4e.com/tools/sql/library.csv?PHPSESSID=f5c34bcea1f2bb189822c02a07afc639%22

# Copy data from csv file to track_raw table
\copy track_raw(title, artist, album, count, rating, len) 
FROM 'library.csv' WITH DELIMITER ',' CSV;

# Insert album titles into an album table with intention of creating UNIQUE PRIMARY KEYS for each title
INSERT INTO album(title) 
SELECT DISTINCT album FROM track_raw 
ORDER BY album;

# Update the track_raw table with FOREIGN KEYs from album table
UPDATE track_raw 
SET album_id = (SELECT id FROM album WHERE album.title = track_raw.album);

# Insert the required columns to track table which will serve as a main table
INSERT INTO track(title, len, album_id) 
SELECT title, len, album_id from track_raw;

# Check if the JOIN table produces the desired result
SELECT track.title, album.title
    FROM track
    JOIN album ON track.album_id = album.id
    ORDER BY track.title LIMIT 3;

# Drop the track_raw table as join of track and album tables will be used to acquire the required information 
DROP TABLE track_raw;
