json.array!(@autotasks) do |autotask|
  json.extract! autotask, :id, :name, :item_count, :time_interval
  json.url autotask_url(autotask, format: :json)
end
