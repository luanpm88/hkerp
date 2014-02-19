json.array!(@contacts) do |contact|
  json.extract! contact, :id, :name, :phone, :mobile, :fax, :email, :address
  json.url contact_url(contact, format: :json)
end
