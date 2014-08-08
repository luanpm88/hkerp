json.array!(@order_statuses) do |order_status|
  json.extract! order_status, :id, :name, :description
  json.url order_status_url(order_status, format: :json)
end
