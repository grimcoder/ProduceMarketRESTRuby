require 'rubygems'
require 'sinatra'
require 'mongo'
require 'bson' # required for .to_json

class ProduceMarketServerMongodb

  MAX_HANDS = 4

  def addId(row)
    row['Id'] = row['_id'].to_s
    row
  end

  def idify(arr)
    arr.each {|i| addId(i)}
  end

  def initialize
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'ProduceMarket')
  end


  def getPrices
    prices = @client['prices'].find.to_a
    idify(prices)
  end

  def getPrice(i)
    prices = @client['prices'].find(:_id => BSON::ObjectId(i)).to_a
    idify(prices)
  end

  def getSales
    prices = @client['sales'].find.to_a
    idify(prices)
  end

  def getSale(i)
    sales = @client['sales'].find(:_id => BSON::ObjectId(i)).to_a
    idify(sales)
  end

  def getPriceChanges
    pricechanges = @client['priceChanges'].find.to_a
    idify(pricechanges)
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
    saveToFileAll
  end

  def deletePrice(id)
    oldprice = @prices.find {|i| i['Id'].to_s == id}
    @prices = @prices.reject {|i| i['Id'].to_s == id}
    oldprice = oldprice.clone
    oldprice['Action'] = 'Delete'
    oldprice['priceWas'] = 'n/a'
    @priceChanges << oldprice

    saveToFileAll
  end


  def deleteSale(id)
    oldprice = @sales.find {|i| i['Id'].to_s == id}
    @sales = @sales.reject {|i| i['Id'].to_s == id}
    saveToFileAll
  end

  def createPrice(ng_params)
    newId = @prices.max{|a,b| a['Id'] <=> b['Id']}['Id'] + 1
    ng_params['Id'] = newId
    @prices << ng_params
    tmp = ng_params.clone
    tmp['Action'] = 'New'
    tmp["priceWas"] = 'n/a'
    @priceChanges << tmp
    saveToFileAll
  end

  def updateSale(ng_params)

    oldSale = @sales.find {|i| i['Id'] == ng_params['Id']}
    @sales = @sales.reject {|i| i['Id'] == ng_params['Id']}
    @sales << ng_params
    saveToFileAll
  end

  def createSale(ng_params)
    newId = @sales.max{|a,b| a['Id'] <=> b['Id']}['Id'] + 1
    ng_params['Id'] = newId
    @sales << ng_params

    saveToFileAll

  end

  def saveToFileAll

    File.open('./data/prices.json', 'w'){ |file| file.write(@prices.to_json)}
    File.open('./data/sales.json', 'w') { |file| file.write(@sales.to_json)}
    File.open('./data/priceChanges.json', 'w') { |file| file.write(@priceChanges.to_json)}

  end
end
