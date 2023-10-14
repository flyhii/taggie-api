# frozen_string_literal: true

require 'http'
require 'yaml'
require 'httparty'

config = YAML.safe_load_file('../config/secrets.yml')

amadeus_base_url = 'https://test.api.amadeus.com/v1/'

amadeus_access_token = config['AMADEUS_TOKEN']

def call_amadeus_post(endpoint, access_token, base_url, _params = {})
  url = "#{base_url}#{endpoint}"
  headers = {
    'Authorization' => "Bearer #{access_token}",
    'Content-Type' => 'application/json'
  }
  response = HTTParty.get(url, headers: headers)
  puts response
  response.parsed_response
end

query_params = {
  origin: 'DMK',
  destination: 'SIN'
}

amadeus_response = {}
amadeus_results = {}

pricing_endpoint = 'shopping/flight-offers/pricing'

response = call_amadeus_post(pricing_endpoint, amadeus_access_token, amadeus_base_url, query_params)
amadeus_response[0] = response

# Extract currency and total price from the response
if response && response['data'] && response['data']['flightOffers']
  currency = response['data']['flightOffers'][0]['price']['currency']
  total_price = response['data']['flightOffers'][0]['price']['total']
  amadeus_results[0] = { currency: currency, total_price: total_price }
else
  # Handle the case where the data structure is not as expected
end

File.write('../spec/fixtures/amadeus_results.yml', amadeus_results.to_yaml)
