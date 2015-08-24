require 'sinatra'
require 'json'

class ProduceMarketServer
  # attr_reader @prices
  MAX_HANDS = 4
  def initialize
    file = File.read('./data/prices.json')
    data_hash = JSON.parse(file)
    @prices = data_hash
  end
  def getPrices
    return @prices
  end

  def getPrice(i)
    return @prices.select { |p| p['Id'].to_s == i }
  end
end

server = ProduceMarketServer.new
set :port, 3001

get '/api/prices' do
  return_message = {}
  if params.has_key?('id')
    return_message = server.getPrice(params['id'])
  else
    return_message = server.getPrices
  end
  return_message.to_json
end

# set CORS
before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
end
