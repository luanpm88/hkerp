json.array!(@supplier_orders) do |supplier_order|
  json.extract! supplier_order, :id, :supplier_id
  json.url supplier_order_url(supplier_order, format: :json)
end
