json.array!(@taxes) do |tax|
  json.extract! tax, :id, :name, :rate
  json.url tax_url(tax, format: :json)
end
