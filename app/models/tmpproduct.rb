class Tmpproduct < ActiveRecord::Base
  has_many :tmpproducttocats, :foreign_key => "product_id", :primary_key => "product_id"
  has_many :tmpcats, :through => :tmpproducttocats, :foreign_key => "category_id", :primary_key => "category_id"
  
  belongs_to :tmpmanu, :foreign_key => "product_manufacturer_id", :primary_key => "manufacturer_id"
end
