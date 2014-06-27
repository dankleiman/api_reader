require 'json'
require 'net/http'
require 'sinatra'
require 'uri'

require 'pry'

use Rack::Session::Pool

######################
#    SET SAMPLE DATA  #
######################

def sample_data
  {"total"=>117, "movies"=>[{"id"=>"771304593", "title"=>"Maleficent", "year"=>2014, "mpaa_rating"=>"PG", "runtime"=>97, "critics_consensus"=>"Angelina Jolie's magnetic performance outshines Maleficent's dazzling special effects; unfortunately, the movie around them fails to justify all that impressive effort.", "release_dates"=>{"theater"=>"2014-05-30"}, "ratings"=>{"critics_rating"=>"Rotten", "critics_score"=>51, "audience_rating"=>"Upright", "audience_score"=>76}, "synopsis"=>"\"Maleficent\" explores the untold story of Disney's most iconic villain from the classic \"Sleeping Beauty\" and the elements of her betrayal that ultimately turn her pure heart to stone. Driven by revenge and a fierce desire to protect the moors over which she presides, Maleficent cruelly places an irrevocable curse upon the human king's newborn infant Aurora. As the child grows, Aurora is caught in the middle of the seething conflict between the forest kingdom she has grown to love and the human kingdom that holds her legacy. Maleficent realizes that Aurora may hold the key to peace in the land and is forced to take drastic actions that will change both worlds forever. (c) Walt Disney Pictures", "posters"=>{"thumbnail"=>"http://content8.flixster.com/movie/11/17/67/11176742_mob.jpg", "profile"=>"http://content8.flixster.com/movie/11/17/67/11176742_pro.jpg", "detailed"=>"http://content8.flixster.com/movie/11/17/67/11176742_det.jpg", "original"=>"http://content8.flixster.com/movie/11/17/67/11176742_ori.jpg"}, "abridged_cast"=>[{"name"=>"Angelina Jolie", "id"=>"162652626", "characters"=>["Maleficent"]}, {"name"=>"Sharlto Copley", "id"=>"770674319", "characters"=>["Stefan"]}, {"name"=>"Elle Fanning", "id"=>"528361349", "characters"=>["Princess Aurora"]}, {"name"=>"Sam Riley", "id"=>"770673828", "characters"=>["Diaval"]}, {"name"=>"Imelda Staunton", "id"=>"162693364", "characters"=>["Knotgrass"]}], "alternate_ids"=>{"imdb"=>"1587310"}, "links"=>{"self"=>"http://api.rottentomatoes.com/api/public/v1.0/movies/771304593.json", "alternate"=>"http://www.rottentomatoes.com/m/maleficent_2014/", "cast"=>"http://api.rottentomatoes.com/api/public/v1.0/movies/771304593/cast.json", "clips"=>"http://api.rottentomatoes.com/api/public/v1.0/movies/771304593/clips.json", "reviews"=>"http://api.rottentomatoes.com/api/public/v1.0/movies/771304593/reviews.json", "similar"=>"http://api.rottentomatoes.com/api/public/v1.0/movies/771304593/similar.json"}}]}
end

def json_data
  JSON.load(session[:json_data]) || sample_data
end

###########################
#     SEARCH METHOD       #
###########################


# This is the web app version of our method, where end values are converted to string while comparing.

def path_finder(value, structure, current_path = "", paths = [])

  if value.class == String && structure.class == String
    if structure =~ /\b#{Regexp.quote(value)}\b/i
      paths << current_path
    end
  elsif value == structure.to_s
    paths << current_path
  elsif structure.class <= Array
    structure.each_with_index do |element, index|
      if path_finder(value, element, current_path + "[#{index}]") != nil
        paths << path_finder(value, element, current_path + "[#{index}]")
      end
    end
  elsif structure.class <= Hash
    structure.each do |key, element|
      if key.class == Symbol
        if path_finder(value, key, current_path + "[:#{key}]") != nil
          paths << path_finder(value, key, current_path + "[:#{key}]")
        end
        if path_finder(value, element, current_path + "[:#{key}]") != nil
          paths << path_finder(value, element, current_path + "[:#{key}]")
        end
      else
        if path_finder(value, key, current_path + "['#{key}']") != nil
          paths << path_finder(value, key, current_path + "['#{key}']")
        end
        if path_finder(value, element, current_path + "['#{key}']") != nil
          paths << path_finder(value, element, current_path + "['#{key}']")
        end
      end
    end
  else
    return nil
  end
  paths.flatten
end

########################
#    OTHER METHODS     #
########################

def valid_json?(json)
  JSON.parse(json)
    return true
  rescue JSON::ParserError
    return false
end

#########################
#       ROUTES          #
#########################

get '/about' do
  erb :about
end

#####################
#  USER DATA INPUT  #
#####################


get '/' do
  session.destroy
  @errors = []
  @json_data = json_data
  erb :index
end

post '/' do
  @errors = []
  if valid_json?(params[:json_data])
    session[:json_data] = params[:json_data]
    puts "SESSION: #{session[:json_data]}"
    redirect '/data'
  else
    @errors << "Please enter a valid JSON object."
    erb :index
  end
end

get '/data' do
  @errors = []
  @json_data = json_data
  erb :'data/show'
end

#####################
# USER SEARCH INPUT #
#####################

post '/data' do
  search_term = params[:query]
  @errors = []
  if search_term == ""
    @errors << "Please enter a search term."
    erb :'search/new'
  else
  search_url = URI.encode("/results?q=#{search_term}")
  redirect search_url
  end
end

get '/results' do
  @search_term = params[:q]
  @results = path_finder(@search_term, json_data)
  @errors = []
  erb :'search/show'
end



