class AddHtmlDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :html_description, :text
  end
end
