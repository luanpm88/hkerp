class ProductPrice < ActiveRecord::Base
  validates :supplier_id, presence: true
  validates :supplier_price, presence: true
  validates :price, presence: true
  
  belongs_to :product
  belongs_to :supplier, :class_name => "Contact"
  
  def price=(new_price)
    self[:price] = new_price.gsub(/[\,]/, '')
  end
  
  def supplier_price=(new_price)
    self[:supplier_price] = new_price.gsub(/[\,]/, '')
  end
end
