require 'sinatra'
require 'sqlite3'
require 'haml'

class ShortenedURL
  def initialize(destination_url)
    @destination_url = destination_url
    @shortened_url = generate_url
    @hits = 0
    @db = SQLite3::Database.new( "urls.db" )
    @db.results_as_hash = true
  end

  def save
    @db.execute("insert into urls values (?, ?, ?)", @shortened_url, @destination_url, @hits)
  end

  def self.increment(short_url)
    db = SQLite3::Database.new( "urls.db" )
    db.results_as_hash = true
    existing_hits = db.execute("select * from urls where shortened_url = ?", short_url)
    existing_hits = existing_hits[0]
    new_hits = existing_hits['hits'].to_i + 1
    db.execute("update urls set hits = ? where shortened_url = ?", new_hits, short_url)
  end

  def shortened
    @shortened_url
  end

  def destination
    @destination_url
  end

  def hits
    @hits
  end

  def shortened_url=(short_url)
    @shortened_url = short_url
  end

  def hits=(set_hits)
    @hits = set_hits
  end

  def self.find_by_shortened_url(short_url)
    db = SQLite3::Database.new( "urls.db" )
    db.results_as_hash = true
    result = db.execute("select * from urls where shortened_url = ?", short_url)

    if result.empty?
      return nil
    else
      result = result[0]  # result comes back as an array of a hash and an array; this makes things easily accessible as hash

      found_url = ShortenedURL.new(result['destination_url'])
      found_url.shortened_url = short_url
      found_url.hits = result['hits']
      return found_url
    end
  end

  def self.list_all
    db = SQLite3::Database.new( "urls.db" )
    db.results_as_hash = true

    array_of_url_objects = []

    rows = db.execute( "select * from urls" ) do |row|
      url_object = ShortenedURL.new(row['destination_url'])
      url_object.shortened_url = row['shortened_url']
      url_object.hits = row['hits']
      array_of_url_objects << url_object
    end
    return array_of_url_objects
  end

  private 

    def generate_url
      # add something here to check db that there doesn't already exist the same (short) url
      new_url = []
      6.times do
        new_url << ('A'..'Z').to_a.sample
      end
      new_url.join
    end
end


# host and port of URL shortening server
url_host = "localhost"
short_url_route = '/shorturl'
url_port = 4567

get '/new' do
  haml :new, :format => :html5
end

post '/new' do
  new_url = ShortenedURL.new(params[:url])
  new_url.save

  "Your new URL is <a href=http://#{url_host}:#{url_port}/#{short_url_route}/#{new_url.shortened}>#{new_url.shortened}</a> which redirects to #{new_url.destination}"
end

get '/shorturl/:short_url' do |url|
  shortened_url = ShortenedURL.find_by_shortened_url(url)

  if shortened_url.nil?
    return "You tried a shortened URL that doesn't exist!"
  else
    ShortenedURL.increment(url)
    redirect shortened_url.destination
  end
end

get '/list' do
  array_of_url_objects = ShortenedURL.list_all

  output = ""
  array_of_url_objects.each do |url_object|
    outputline = "<a href=http://#{url_host}:#{url_port}/#{short_url_route}/#{url_object.shortened}>#{url_object.shortened}</a> #{url_object.destination} #{url_object.hits}<br>"
    output << outputline
  end
  return output
end

