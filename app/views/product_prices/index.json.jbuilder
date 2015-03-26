json.array!(@product_prices) do |product_price|
  json.extract! product_price, :id, :product_id, :price, :supplier_price, :supplier_id
  json.url product_price_url(product_price, format: :json)
end
