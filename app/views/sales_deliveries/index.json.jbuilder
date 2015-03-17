json.array!(@sales_deliveries) do |sales_delivery|
  json.extract! sales_delivery, :id, :order_id
  json.url sales_delivery_url(sales_delivery, format: :json)
end
