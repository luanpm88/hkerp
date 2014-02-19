class CreateParentContacts < ActiveRecord::Migration
  def change
    create_table :parent_contacts do |t|
      t.integer :contact_id
      t.integer :parent_id
    end
  end
end
