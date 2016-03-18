class CreateContactTypesContacts < ActiveRecord::Migration
  def change
    create_table :contact_types_contacts do |t|
      t.integer :contact_id
      t.integer :contact_type_id

      t.timestamps null: false
    end
  end
end
