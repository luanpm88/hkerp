class AddUserIdToManufacturers < ActiveRecord::Migration
  def change
    add_column :manufacturers, :user_id, :integer
  end
end
