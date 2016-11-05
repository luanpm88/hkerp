class AddIsSoftToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_soft, :boolean, default: false
  end
end
