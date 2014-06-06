require 'json'
require 'net/http'
require 'sinatra'
require 'uri'
require 'pry'

enable :sessions

######################
#    MAKE API CALL   #
######################

if !ENV.has_key?("ROTTEN_TOMATOES_API_KEY")
  puts "You need to set the ROTTEN_TOMATOES_API_KEY environment variable."
  exit 1
end

def query_api
  api_key = ENV["ROTTEN_TOMATOES_API_KEY"]
  uri = URI("http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=#{api_key}")

  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

def api_results
  @api_results ||= query_api
end

def json_data
  JSON.load(session[:json_data]) || api_results
end

#####################################################
# Given a value and a compound data structure,      #
# returns the position in the strucure,             #
# formatted so you can referrence it in your code   #
#####################################################

def path_finder(value, structure, current_path = "", paths = [])

  if value.class == String && structure.class == String
    if structure =~ /\b#{Regexp.quote(value)}\b/i
      paths << current_path
    end
  elsif value == structure
    paths << current_path
  elsif structure.is_a?(Array)
    structure.each_with_index do |element, index|
      if path_finder(value, element, current_path + "[#{index}]") != nil
        paths << path_finder(value, element, current_path + "[#{index}]")
      end
    end
  elsif structure.is_a?(Hash)
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

def valid_json?(json)
  JSON.parse(json)
    return true
  rescue JSON::ParserError
    return false
end
#########################
#       ROUTES          #
#########################

get '/' do
  erb :index
end

get '/about' do
  erb :about
end
get '/search' do
  @json_data = json_data
  @errors = []
  erb :'search/new'
end

#####################
# USER SEARCH INPUT #
#####################

post '/new' do
  search_term = params[:query]
  @errors = []
  if search_term == ""
    @errors << "Please enter a search term."
    erb :'search/new'
  else
  search_url = URI.encode("/results/#{search_term}")
  redirect search_url
  end
end

get '/results/:query' do
  @search_term = params[:query]
  @results = path_finder(@search_term, json_data)
  @errors = []
  erb :'search/show'
end


#####################
#  USER DATA INPUT  #
#####################

get '/data/new' do
  session.destroy
  @errors = []
  @json_data = json_data
  erb :'data/new'
end

post '/data/new' do
  @errors = []
  if valid_json?(params[:json_data])
    session[:json_data] = params[:json_data]
    redirect '/data'
  else
    @errors << "Please enter a valid JSON object."
    erb :'data/new'
  end
end

get '/data' do
  @json_data = json_data
  erb :'data/show'
end





