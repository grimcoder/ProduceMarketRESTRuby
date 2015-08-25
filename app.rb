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

  def updatePrice(ng_params)
    oldprice = @prices.find {|i| i['Id'] == ng_params['Id']}
    pricewas = oldprice['Price']
    @prices = @prices.reject {|i| i['Id'] == ng_params['Id']}
    @prices << ng_params
    tmp = ng_params.clone
    action = 'Edit'
    tmp['Action'] = 'Edit'
    tmp["priceWas"] = oldprice['Price']
    @priceChanges << tmp
  end

  def deletePrice(id)
    oldprice = @prices.find {|i| i['Id'].to_s == id}
    @prices = @prices.reject {|i| i['Id'].to_s == id}
    oldprice = oldprice.clone
    oldprice['Action'] = 'Delete'
    oldprice['priceWas'] = 'n/a'
    @priceChanges << oldprice
  end


  def deleteSale(id)
    oldprice = @sales.find {|i| i['Id'].to_s == id}
    @sales = @sales.reject {|i| i['Id'].to_s == id}

  end

  def createPrice(ng_params)
    newId = @prices.max{|a,b| a['Id'] <=> b['Id']}['Id'] + 1
    ng_params['Id'] = newId
    @prices << ng_params
    tmp = ng_params.clone
    tmp['Action'] = 'New'
    tmp["priceWas"] = 'n/a'
    @priceChanges << tmp
  end

  def updateSale(ng_params)

    oldSale = @sales.find {|i| i['Id'] == ng_params['Id']}
    @sales = @sales.reject {|i| i['Id'] == ng_params['Id']}
    @sales << ng_params
  end

  def createSale(ng_params)
    newId = @sales.max{|a,b| a['Id'] <=> b['Id']}['Id'] + 1
    ng_params['Id'] = newId
    @sales << ng_params

  end
end

server = ProduceMarketServer.new
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
