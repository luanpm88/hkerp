namespace :mytask do
  desc "Truncate all tables"
  task drop_all_table: :environment do
    conn = ActiveRecord::Base.connection
    tables = conn.execute("SELECT * FROM information_schema.tables WHERE table_schema = 'public'")
    tables.each { |t| conn.execute("DROP TABLE #{t["table_name"]}") }
  end

end
