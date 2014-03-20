class CreateTmpcats < ActiveRecord::Migration
  def change
    create_table :tmpcats do |t|
      t.text :category_id
      t.text :category_image
      t.text :category_parent_id
      t.text :category_publish
      t.text :category_ordertype
      t.text :category_template
      t.text :category_ordering
      t.text :category_add_date
      t.text :products_page
      t.text :products_row
      t.text :name_en_GB
      t.text :alias_en_GB
      t.text :short_description_en_GB
      t.text :description_en_GB
      t.text :meta_title_en_GB
      t.text :meta_description_en_GB
      t.text :meta_keyword_en_GB
      t.text :name_vi_VN
      t.text :alias_vi_VN
      t.text :short_description_vi_VN
      t.text :description_vi_VN
      t.text :meta_title_vi_VN
      t.text :meta_description_vi_VN
      t.text :meta_keyword_vi_VN
      
      
    end
  end
end
