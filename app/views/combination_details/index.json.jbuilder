json.array!(@combination_details) do |combination_detail|
  json.extract! combination_detail, :id, :combination_id, :product_id, :stock_before, :quantity, :stock_after
  json.url combination_detail_url(combination_detail, format: :json)
end
