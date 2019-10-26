require 'sinatra'
require 'json'
require 'net/http'
require 'shotgun'
require 'pry'
require './app/lib/rtd_station'
require './app/lib/rtd_place_detail'

get '/' do
#to make operation dynamic, need the following:
# 1. api_key needs to be ENV

#Will add more cities from Douglas, Arapahoe, Adams, Broomfield and Boulder counties.
cities = ['Denver,CO', 'Lakewood,CO', 'arvada,CO', 'Arvada,CO', 'westminster,CO', 'wheat ridge,CO', 'Golden,CO', 'edgewater,CO', 'mountain view,CO', 'bow mar,CO', 'littleton,CO', 'superior,CO', 'lakeside,CO']
#Geocode endpoint returns coordinates for a given city
cities.map do |city|
  geocode_endpoint = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyDxsdzwJ2jFqPRbyi8Q434HKAURziPojVc&address=#{city}"

  geocode_uri = URI.parse(URI.encode(geocode_endpoint))
  geocode_api_response = Net::HTTP.get(geocode_uri)
  geocode_parsed_coords = JSON.parse(geocode_api_response, symbolize_names: true)[:results][0][:geometry][:location]

  latitude = geocode_parsed_coords[:lat]
  longitude = geocode_parsed_coords[:lng]

  #nearbysearch endpoint below to obtain place_ids. this will be used to obtain place details from a separate API call, also below.
    nearbysearch_endpoint = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDxsdzwJ2jFqPRbyi8Q434HKAURziPojVc&radius=8046&keyword=Park-N-Ride&location=#{latitude}, #{longitude}"
#Note: Park-N-Ride only returns limited RTD locations.  Need to include search for PnR as well due to RTD's poor data formatting.
    uri = URI.parse(URI.encode(nearbysearch_endpoint))
    api_response = Net::HTTP.get(uri)
    parsed_locations = JSON.parse(api_response, symbolize_names: true)

    nearbysearch_results = parsed_locations[:results]
    rtd_place_ids = nearbysearch_results.map do |hash|
      RtdPlaceId.new(hash)
    end

    #passing place_ids into Place Details endpoint to obtain complete addresses and names for nearby RTD stations.
    rtd_place_ids.map do |place|
      place_details_endpoint = "https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyDxsdzwJ2jFqPRbyi8Q434HKAURziPojVc&placeid=#{place.place_id}"

      place_details_uri = URI.parse(URI.encode(place_details_endpoint))
      place_details_response = Net::HTTP.get(place_details_uri)
      parsed_location_details = JSON.parse(place_details_response, symbolize_names: true)
      name = parsed_location_details[:result][:name]
      address = parsed_location_details[:result][:formatted_address]
      RtdPlaceDetail.new(name, address)
    end
  end
end
