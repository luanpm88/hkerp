json.array!(@notifications) do |notification|
  json.extract! notification, :id, :title, :description, :image, :url, :viewed, :user_id, :type
  json.url notification_url(notification, format: :json)
end
