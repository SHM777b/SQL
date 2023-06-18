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

DROP TABLE IF EXISTS track_raw;
CREATE TABLE track_raw
 (title TEXT, artist TEXT, album TEXT, album_id INTEGER,
  count INTEGER, rating INTEGER, len INTEGER);
  
/*
We will ignore the artist field for this assignment and focus on the many-to-one relationship between tracks and albums.
If you run the program multiple times in testing or with different files, make sure to empty out the data before each run.

Load this CSV data file into the track_raw table using the \copy command. 
Then write SQL commands to insert all of the distinct albums into the album table 
(creating their primary keys) and then set the album_id in the track_raw table
*/

# Copy data from csv file to track_raw table
\copy track_raw(title, artist, album, count, rating, len) 
FROM 'library.csv' WITH DELIMITER ',' CSV;

# Insert album titles into an album table with intention of creating UNIQUE PRIMARY KEYS for each title
INSERT INTO album(title) 
SELECT DISTINCT album FROM track_raw 
ORDER BY album;

# Update the track_raw table with FOREIGN KEYs from albumk table
UPDATE track_raw 
SET album_id = (SELECT id FROM album WHERE album.title = track_raw.album);

# Insert the required columns to track table which will serve as a main table
INSERT INTO track(title, len, album_id) 
SELECT title, len, album_id from track_raw;

# Drop the track_raw table as join of track and album tables will be used to acquire the required information 
DROP TABLE track_raw;
