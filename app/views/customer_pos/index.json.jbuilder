json.array!(@customer_pos) do |customer_po|
  json.extract! customer_po, :id, :code, :filename
  json.url customer_po_url(customer_po, format: :json)
end
