class CreateTmpmanus < ActiveRecord::Migration
  def change
    create_table :tmpmanus do |t|
      t.text :manufacturer_id
      t.text :manufacturer_url
      t.text :manufacturer_logo
      t.text :manufacturer_publish
      t.text :products_page
      t.text :products_row
      t.text :ordering
      t.text :name_en_gb
      t.text :alias_en_gb
      t.text :short_description_en_gb
      t.text :description_en_gb
      t.text :meta_title_en_gb
      t.text :meta_description_en_gb
      t.text :meta_keyword_en_gb
      t.text :name_vi_vn
      t.text :alias_vi_vn
      t.text :short_description_vi_vn
      t.text :description_vi_vn
      t.text :meta_title_vi_vn
      t.text :meta_description_vi_vn
      t.text :meta_keyword_vi_vn

      t.timestamps
    end
  end
end
