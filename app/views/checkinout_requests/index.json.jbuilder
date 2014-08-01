json.array!(@checkinout_requests) do |checkinout_request|
  json.extract! checkinout_request, :id, :user_id, :check_time, :content, :status
  json.url checkinout_request_url(checkinout_request, format: :json)
end
