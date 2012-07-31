DROP TABLE url_shorten;

CREATE TABLE url_shorten (
      url TEXT, 
      redirect_url TEXT,
      hits INTEGER DEFAULT 0
);
