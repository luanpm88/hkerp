json.array!(@worksheet_expenses) do |worksheet_expense|
  json.extract! worksheet_expense, :id, :name, :price, :type_name, :description, :creator_id
  json.url worksheet_expense_url(worksheet_expense, format: :json)
end
