require 'sqlite3'

# Open a database
db = SQLite3::Database.new( "url_shorten.db" )

db.results_as_hash = true
db.execute( "select * from url_shorten" ) do |row|
  #url, redirect_url = row.split('|')
  puts "url: #{row[0]}, redirect_url: #{row[1]}"
  # puts "url: #{row['url']}, redirect_url: #{row['redirect_url']}"
end

db.close