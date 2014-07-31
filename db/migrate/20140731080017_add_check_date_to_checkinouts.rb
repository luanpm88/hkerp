class AddCheckDateToCheckinouts < ActiveRecord::Migration
  def change
    add_column :checkinouts, :check_date, :date
  end
end
