class CreateAgentsContacts < ActiveRecord::Migration
  def change
    create_table :agents_contacts do |t|
      t.integer :agent_id
      t.integer :contact_id

      t.timestamps
    end
  end
end
