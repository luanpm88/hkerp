json.array!(@commission_programs) do |commission_program|
  json.extract! commission_program, :id, :time_interval, :min_amount, :max_amount, :pushlished_at
  json.url commission_program_url(commission_program, format: :json)
end
