class AddTmpmanuToManufactures < ActiveRecord::Migration
  def change
    add_column :manufacturers, :tmpmenu, :integer
  end
end
