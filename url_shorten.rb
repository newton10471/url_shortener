require 'sinatra'
require 'sqlite3'

def increment_hit(db, url)
  # get existing # hits for this URL

  # increment it
  # write new value to db
  return 0
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
  # Execute a few inserts
  {
    # "url" => url,
    # "redirect_url" => redirect_url,
    url => redirect_url,
  }.each do |pair|
    db.execute "insert into url_shorten values ( ?, ? )", pair
  end
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
  # haml :new, :format => :html5
  "<html>
    <body>
      <form action='/new' method='POST'>
        <input type='url' name='url' placeholder='Enter URL here'>
        <input type='submit' value='GO'>
      </form>
    </body>
  </html>"
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
    outputline = "<a href=http://l#{url_host}:#{url_port}/#{row[0]}>#{row[0]}</a> #{row[1]}<br>"
    output << outputline
  end
  return output
end
