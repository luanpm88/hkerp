json.array!(@combinations) do |combination|
  json.extract! combination, :id, :product_id, :quantity
  json.url combination_url(combination, format: :json)
end
