class AddCityIdsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :city_id, :integer
  end
end
