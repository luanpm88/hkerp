json.array!(@checkinouts) do |checkinout|
  json.extract! checkinout, :id, :user_id, :check_time
  json.url checkinout_url(checkinout, format: :json)
end
