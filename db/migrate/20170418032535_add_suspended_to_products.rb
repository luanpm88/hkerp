class AddSuspendedToProducts < ActiveRecord::Migration
  def change
    add_column :products, :suspended, :boolean, default: false
  end
end
