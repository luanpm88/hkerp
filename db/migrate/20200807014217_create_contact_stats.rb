class CreateContactStats < ActiveRecord::Migration
  def change
    create_table :contact_stats do |t|
      t.integer :contact_id
      t.float :buy_last_6_months
      t.float :buy_last_1_year
      t.float :buy_last_3_years
      t.float :buy_all_time

      t.timestamps null: false
    end
  end
end
