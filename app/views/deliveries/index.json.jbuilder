json.array!(@deliveries) do |delivery|
  json.extract! delivery, :id, :order_id, :user_id
  json.url delivery_url(delivery, format: :json)
end
