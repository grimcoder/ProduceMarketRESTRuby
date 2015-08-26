class ProduceMarketServer

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
