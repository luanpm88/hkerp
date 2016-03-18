class AddTipContactIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tip_contact_id, :integer
  end
end
