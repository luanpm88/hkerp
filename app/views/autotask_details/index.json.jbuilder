json.array!(@autotask_details) do |autotask_detail|
  json.extract! autotask_detail, :id, :autotask_id, :item_count, :time_interval
  json.url autotask_detail_url(autotask_detail, format: :json)
end
