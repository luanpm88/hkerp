json.array!(@delivery_details) do |delivery_detail|
  json.extract! delivery_detail, :id, :delivery_id, :order_detail_id, :quantity
  json.url delivery_detail_url(delivery_detail, format: :json)
end
