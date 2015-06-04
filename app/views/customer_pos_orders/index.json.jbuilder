json.array!(@customer_pos_orders) do |customer_pos_order|
  json.extract! customer_pos_order, :id, :order_id, :customer_po_id
  json.url customer_pos_order_url(customer_pos_order, format: :json)
end
