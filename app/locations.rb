require 'sinatra'
require 'json'
require 'net/http'
require 'shotgun'
require 'pry'
require './app/lib/rtd_station'
require './app/lib/rtd_place_detail'

# get'/' do
#   'This is a microservice app providing pickup and drop off locaitons for the ShredShare rideshare app.'
# end

get '/' do
#nearbysearch endpoint for place_ids. this will be used to obtain place details from a separate API call.
#hard coded API key, radius and location (Lone Tree)
  nearbysearch_endpoint = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDxsdzwJ2jFqPRbyi8Q434HKAURziPojVc&radius=8046&keyword=RTD&location=39.536482, -104.8970678"

  uri = URI.parse(URI.encode(nearbysearch_endpoint))
  api_response = Net::HTTP.get(uri)
  parsed_locations = JSON.parse(api_response, symbolize_names: true)

  nearbysearch_results = parsed_locations[:results]
  rtd_place_ids = nearbysearch_results.map do |hash|
    RtdPlaceId.new(hash)
  end

  #passing place_ids into Place Details endpoint to obtain complete addresses for nearby RTD stations.
  #hard coding for now: api key, location, etc.

  place_details_endpoint = "https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyDxsdzwJ2jFqPRbyi8Q434HKAURziPojVc&placeid=ChIJb-T0ZwuFbIcRgmXrh3VSFpI"

  place_details_uri = URI.parse(URI.encode(place_details_endpoint))
  place_details_response = Net::HTTP.get(place_details_uri)
  parsed_location_details = JSON.parse(place_details_response, symbolize_names: true)

  name = parsed_location_details[:result][:name]
  address = parsed_location_details[:result][:formatted_address]
  x =  RtdPlaceDetail.new(name, address)
  binding.pry
end


# get '/' do
#   response = Faraday.get "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDxsdzwJ2jFqPRbyi8Q434HKAURziPojVc&radius=8046&keyword=RTD&location=39.7541,-105.0002"
#
# end
