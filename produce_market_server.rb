require 'sinatra'
require 'json'

class ProduceMarketServer
  # attr_reader @prices
  MAX_HANDS = 4
  def initialize
    file = File.read('./data/prices.json')
    data_hash = JSON.parse(file)
    @prices = data_hash

    file = File.read('./data/sales.json')
    data_hash = JSON.parse(file)
    @sales = data_hash

    file = File.read('./data/priceChanges.json')
    data_hash = JSON.parse(file)
    @priceChanges = data_hash
  end


  def getPrices
    return @prices
  end

  def getPrice(i)
    return @prices.select { |p| p['Id'].to_s == i }
  end

  def getSales
    return @sales
  end

  def getSale(i)
    return @sales.select { |p| p['Id'].to_s == i }
  end


  def getPriceChanges
    return @priceChanges
  end



end

server = ProduceMarketServer.new
set :port, 3001

# set CORS
before do
  # content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
end

get '/api/prices' do
  return_message = {}
  if params.has_key?('id')
    return_message = server.getPrice(params['id'])
  else
    return_message = server.getPrices
  end
  return_message.to_json
end

get '/api/sales' do
  return_message = {}
  if params.has_key?('id')
    return_message = server.getSale(params['id'])
  else
    return_message = server.getSales
  end
  return_message.to_json
end

get '/api/priceChanges' do

  return_message = server.getPriceChanges
  return_message.to_json
end
