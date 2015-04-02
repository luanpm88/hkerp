json.array!(@product_parts) do |product_part|
  json.extract! product_part, :id, :product_id, :part_id, :quantity
  json.url product_part_url(product_part, format: :json)
end
