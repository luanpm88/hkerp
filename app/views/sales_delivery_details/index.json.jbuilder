json.array!(@sales_delivery_details) do |sales_delivery_detail|
  json.extract! sales_delivery_detail, :id, :sales_delivery_id, :order_detail_id, :quantity
  json.url sales_delivery_detail_url(sales_delivery_detail, format: :json)
end
