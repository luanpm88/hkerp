json.array!(@city_types) do |city_type|
  json.extract! city_type, :id, :name
  json.url city_type_url(city_type, format: :json)
end
