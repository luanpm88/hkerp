json.array!(@orders) do |order|
  json.extract! order, :id, :customer_id, :supplier_id, :agent_id, :shipping_place, :payment_method_id, :payment_deadline
  json.url order_url(order, format: :json)
end
