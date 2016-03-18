json.array!(@notifications) do |notification|
  json.extract! notification, :id, :user_id, :sender_id, :sender_id, :message, :read, :url
  json.url notification_url(notification, format: :json)
end
