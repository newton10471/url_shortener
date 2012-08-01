DROP TABLE urls;

CREATE TABLE urls (
      shortened_url TEXT, 
      destination_url TEXT,
      hits INTEGER DEFAULT 0
);
