json.array!(@supplier_order_details) do |supplier_order_detail|
  json.extract! supplier_order_detail, :id, :supplier_order_id, :product_id, :quantity, :price, :product_name
  json.url supplier_order_detail_url(supplier_order_detail, format: :json)
end
