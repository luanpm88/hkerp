class CreateTmpproducts < ActiveRecord::Migration
  def change
    create_table :tmpproducts do |t|
      t.text :product_id
      t.text :product_ean
      t.text :product_quantity
      t.text :unlimited
      t.text :product_availability
      t.text :product_date_added
      t.text :date_modify
      t.text :product_publish
      t.text :product_tax_id
      t.text :product_template
      t.text :product_url
      t.text :product_old_price
      t.text :product_buy_price
      t.text :product_price
      t.text :min_price
      t.text :different_prices
      t.text :product_weight
      t.text :product_thumb_image
      t.text :product_name_image
      t.text :product_full_image
      t.text :product_manufacturer_id
      t.text :product_is_add_price
      t.text :average_rating
      t.text :reviews_count
      t.text :delivery_times_id
      t.text :hits
      t.text :weight_volume_units
      t.text :basic_price_unit_id
      t.text :label_id
      t.text :vendor_id
      t.text :name_en_gb
      t.text :alias_en_gb
      t.text :short_description_en_gb
      t.text :description_en_gb
      t.text :meta_title_en_gb
      t.text :meta_description_en_gb
      t.text :meta_keyword_en_gb
      t.text :product_warranty
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
