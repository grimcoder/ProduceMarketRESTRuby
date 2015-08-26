require 'sinatra'
require 'json'
require './produce_market_server'
require './produce_market_server_mongodb'

if ARGV[0] == 'mongodb'
  server = ProduceMarketServerMongodb.new
else
  server = ProduceMarketServer.new
end

set :port, 3001
# set CORS

before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => %w(OPTIONS,GET,POST,DELETE,PUT)
end

options '*' do
  response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  200
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

delete '/api/prices' do
  return_message = {}
  if params.has_key?('id')
    server.deletePrice(params['id'])
  end
  return_message.to_json
end

delete '/api/sales' do
  return_message = {}
  if params.has_key?('id')
    server.deleteSale(params['id'])
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

get '/api/reports/prices' do
  return_message = server.getPriceChanges
  return_message.to_json
end

post('/api/prices') do
  ng_params = JSON.parse(request.body.read)
  if ng_params.has_key?('Id') #update
    server.updatePrice(ng_params)
  else #create
    server.createPrice(ng_params)
  end
  return "success".to_json
end

post('/api/sales') do
  ng_params = JSON.parse(request.body.read)
  if ng_params.has_key?('Id')
    server.updateSale(ng_params)
  else
    server.createSale(ng_params)
  end
  return "success".to_json
end
