class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :state_id
      t.integer :city_type_id

      t.timestamps null: false
    end
  end
end
