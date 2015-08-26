require 'rubygems'
require 'sinatra'
require 'mongo'
require 'bson' # required for .to_json

class ProduceMarketServerMongodb

  MAX_HANDS = 4

  def addObjectId(row)
    row['Id'] = row['_id'].to_s
    row['_id'] = BSON::ObjectId(row['_id'])
    row
  end

  def addId(row)
    row['Id'] = row['_id'].to_s
    row['_id'] = row['_id'].to_s
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

    id = ng_params['Id']
    ng_params = addObjectId(ng_params)
    prices = @client['prices'].find(:_id => BSON::ObjectId(id)).first
    pricewas = prices['Price']
    @client['prices'].find(:_id => BSON::ObjectId(id)).delete_one
    @client['prices'].insert_one(ng_params)

    tmp = ng_params.clone
    tmp['Action'] = 'Edit'
    tmp["priceWas"] = pricewas
    @client['priceChanges'].insert_one(tmp)

  end

  def deletePrice(id)
    oldprice = @client['prices'].find(:_id => BSON::ObjectId(id)).first
    @client['prices'].find(:_id => BSON::ObjectId(id)).delete_one

    oldprice['Action'] = 'Delete'
    oldprice["priceWas"] = 'n/a'
    @client['priceChanges'].insert_one(oldprice)
  end

  def deleteSale(id)
    @client['sales'].find(:_id => BSON::ObjectId(id)).delete_one
  end

  def createPrice(ng_params)

    @client['prices'].insert_one(ng_params)
    tmp = ng_params.clone
    tmp['Action'] = 'New'
    tmp["priceWas"] = 'n/a'
    @client['priceChanges'].insert_one(tmp)

  end

  def updateSale(ng_params)
    ng_params = addObjectId(ng_params)
    @client['sales'].find(:_id => BSON::ObjectId(ng_params['Id'])).delete_one
    @client['sales'].insert_one(ng_params)
  end

  def createSale(ng_params)
    @client['sales'].insert_one(ng_params)
  end

  def saveToFileAll
    File.open('./data/prices.json', 'w'){ |file| file.write(@prices.to_json)}
    File.open('./data/sales.json', 'w') { |file| file.write(@sales.to_json)}
    File.open('./data/priceChanges.json', 'w') { |file| file.write(@priceChanges.to_json)}
  end
end
