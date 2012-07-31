require 'sinatra'
require 'sqlite3'
require 'haml'

class ShortenedURL
  def initialize(destination_url)
    @destination_url = destination_url
    @shortened_url = generate_url
    @db = SQLite3::Database.new( "url_shorten.db" )
  end

  def save
    @db.execute("insert into url_shorten values (?, ?)", @destination_url, @shortened_url)
  end

  # get stored url

  def increment
    existing_hits = @db.execute("select hits from url_shorten where url = ?", url)
    new_hits = existing_hits[0][0].to_i + 1
    @db.execute("update url_shorten set hits = ? where url = ?", new_hits, url)
  end

  def shortened
    @shortened_url
  end

  def destination
    @destination_url
  end

  def self.find_by_shortened_url(short_url)
    # fill me in
    # and what the hell is self
    # should return an instance of ShortenedURL
    result = @db.execute("select hits from urls where url = ?", short_url)
    return result
  end

  private 

    def generate_url
      new_url = []
      6.times do
        new_url << ('A'..'Z').to_a.sample
      end
      new_url.join
    end
end

# def increment_hit(db, url)
#   existing_hits = db.execute("select hits from url_shorten where url = \"#{url}\" ")
#   new_hits = existing_hits[0][0].to_i + 1
#   db.execute("update url_shorten set hits = (\"#{new_hits}\") where url = \"#{url}\" ")
# end 

# def makeurl(db, url, redirect_url)
#   posturl = "/" + url

#   puts "URL: #{posturl}, redirect: #{redirect_url}"

#   get posturl do
#     increment_hit(db, url)
#     redirect redirect_url
#   end
# end

# def write_url_to_db(db,url,redirect_url)
#     db.execute( "insert into url_shorten (url, redirect_url, hits) values (\"#{url}\", \"#{redirect_url}\", 0)" )
# end

# def reload_urls(db)
#   db.execute( "select * from url_shorten" ) do |row|
#     makeurl(db, row[0], row[1])
#   end
# end

# host and port of URL shortening server
url_host = "localhost"
url_port = 4567

# Open a database

# reload_urls(db)

get '/new' do
  haml :new, :format => :html5
end

post '/new' do
  new_url = ShortenedURL.new(params[:url])
  new_url.save
  # new_url = []
  # base_url = ["http://#{url_host}:#{url_port}/"]
  # 6.times do 
  #   new_url << ('A'..'Z').to_a.sample
  # end
  
  # makeurl(db, new_url.join, params["url"])
  # write_url_to_db(db, new_url.join, params["url"])

  "Your new URL is <a href=#{new_url.shortened_url}>#{new_url.shortened}</a> which redirects to #{new_url.destination}"
end

# get '/list' do
#   # Find a few rows
#   output = ""
#   rows = db.execute( "select * from url_shorten" ) do |row|
#     outputline = "<a href=http://#{url_host}:#{url_port}/#{row[0]}>#{row[0]}</a> #{row[1]} #{row[2]}<br>"
#     output << outputline
#   end
#   return output
# end

get '/:short_url' do |url|
  redirect ShortenedURL.find_by_shortened_url(url).destination
end
