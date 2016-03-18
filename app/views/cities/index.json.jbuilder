json.array!(@cities) do |city|
  json.extract! city, :id, :name, :state_id, :city_type
  json.url city_url(city, format: :json)
end
