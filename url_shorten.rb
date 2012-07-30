require 'sinatra'
require 'sqlite3'
require 'haml'

def increment_hit(db, url)
  # get existing # hits for this URL
  existing_hits = db.execute("select hits from url_shorten where url = \"#{url}\" ")
  # increment it
  new_hits = existing_hits[0][0].to_i + 1
  # write new value to db
  db.execute("update url_shorten set hits = (\"#{new_hits}\") where url = \"#{url}\" ")
end 

def makeurl(db, url, redirect_url)
  posturl = "/" + url

  puts "URL: #{posturl}, redirect: #{redirect_url}"

  get posturl do
    increment_hit(db, url)
    redirect redirect_url
  end
end

def write_url_to_db(db,url,redirect_url)
    db.execute( "insert into url_shorten (url, redirect_url, hits) values (\"#{url}\", \"#{redirect_url}\", 0)" )
end

def reload_urls(db)
  db.execute( "select * from url_shorten" ) do |row|
    makeurl(db, row[0], row[1])
  end
end

# host and port of URL shortening server
url_host = "localhost"
url_port = 4567

# Open a database
db = SQLite3::Database.new( "url_shorten.db" )

reload_urls(db)

get '/new' do
  haml :new, :format => :html5
end

post '/new' do
  new_url = []
  base_url = ["http://#{url_host}:#{url_port}/"]
  6.times do 
    new_url << ('A'..'Z').to_a.sample
  end
  
  makeurl(db, new_url.join, params["url"])
  write_url_to_db(db, new_url.join, params["url"])

  "Your new URL is <a href=#{new_url.join}>#{new_url.join}</a> which redirects to #{params["url"]}"
end

get '/list' do
  # Find a few rows
  output = ""
  rows = db.execute( "select * from url_shorten" ) do |row|
    outputline = "<a href=http://#{url_host}:#{url_port}/#{row[0]}>#{row[0]}</a> #{row[1]} #{row[2]}<br>"
    output << outputline
  end
  return output
end
