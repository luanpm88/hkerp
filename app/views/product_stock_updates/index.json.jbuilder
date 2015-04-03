json.array!(@product_stock_updates) do |product_stock_update|
  json.extract! product_stock_update, :id, :product_id, :quantity, :serial_numbers
  json.url product_stock_update_url(product_stock_update, format: :json)
end
