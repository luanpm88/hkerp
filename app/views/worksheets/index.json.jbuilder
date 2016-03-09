json.array!(@worksheets) do |worksheet|
  json.extract! worksheet, :id, :user_id, :creator_id, :other_amount, :other_description
  json.url worksheet_url(worksheet, format: :json)
end
