class CreateCityTypes < ActiveRecord::Migration
  def change
    create_table :city_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
