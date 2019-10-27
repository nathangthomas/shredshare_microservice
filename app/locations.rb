require 'dotenv'
Dotenv.load
require 'sinatra'
require 'sinatra/json'
require 'json'
require 'net/http'
require 'shotgun'
require 'pry'
require './app/lib/rtd_place_id'
require './app/lib/rtd_location'
require 'rubygems'
require 'bundler'

  get'/' do
    'This is a microservice application exposing custom APIs for the ShredShare ride share application that can be visitied at shred-share.herokuapp.com'

  end

  get '/rtd_locations/index' do
  #to make operation dynamic, need the following:
  # 1. api_key needs to be ENV

  #Will add more cities from Douglas, Arapahoe, Adams, Broomfield and Boulder counties.
  cities = ['Denver,CO', 'Lakewood,CO', 'Arvada,CO','Westminster,CO', 'Wheat Ridge,CO', 'Golden,CO', 'Edgewater,CO', 'Mountain View,CO', 'Bow Mar,CO', 'Littleton,CO', 'Superior,CO', 'Lakeside,CO']
  #Geocode endpoint returns coordinates for a given city
  locations = cities.map do |city|
    geocode_endpoint = "https://maps.googleapis.com/maps/api/geocode/json?key=#{ENV['GOOGLE_API_KEY']}&address=#{city}"

    geocode_uri = URI.parse(URI.encode(geocode_endpoint))
    geocode_api_response = Net::HTTP.get(geocode_uri)
    geocode_parsed_coords = JSON.parse(geocode_api_response, symbolize_names: true)[:results][0][:geometry][:location]

    latitude = geocode_parsed_coords[:lat]
    longitude = geocode_parsed_coords[:lng]

    #nearbysearch endpoint below to obtain place_ids. this will be used to obtain place details from a separate API call, also below.
      nearbysearch_endpoint = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{ENV['GOOGLE_API_KEY']}&radius=8046&keyword=Park-N-Ride&location=#{latitude}, #{longitude}"
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
        place_details_endpoint = "https://maps.googleapis.com/maps/api/place/details/json?key=#{ENV['GOOGLE_API_KEY']}&placeid=#{place.place_id}"

        place_details_uri = URI.parse(URI.encode(place_details_endpoint))
        place_details_response = Net::HTTP.get(place_details_uri)
        parsed_location_details = JSON.parse(place_details_response, symbolize_names: true)
        name = parsed_location_details[:result][:name]
        address = parsed_location_details[:result][:formatted_address]
        RtdLocation.new(name, address)
      end
    end
#the location below actually refers to a single city
    location_arrays = locations.map! do |city|
      city.map! do |location|
        location_hash = {name: location.name, address: location.address, city: location.city}
        location_hash.to_json
      end
    end
    cities.zip(location_arrays).to_s
  end
