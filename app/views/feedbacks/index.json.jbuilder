json.array!(@feedbacks) do |feedback|
  json.extract! feedback, :id, :user_id, :title, :content, :image, :status
  json.url feedback_url(feedback, format: :json)
end
