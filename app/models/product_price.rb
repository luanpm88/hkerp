class ProductPrice < ActiveRecord::Base
  validates :supplier_id, presence: true
  validates :supplier_price, presence: true
  validates :price, presence: true
  
  belongs_to :product
  belongs_to :supplier, :class_name => "Contact"
  
  belongs_to :user
  
  has_many :product_prices
  
  def price=(new_price)
    self[:price] = new_price.to_s.gsub(/[\,]/, '')
  end
  
  def supplier_price=(new_price)
    self[:supplier_price] = new_price.to_s.gsub(/[\,]/, '')
  end
  
  def price_formated
    price.nil? ? "" : Order.format_price(price)
  end
  
  def supplier_price_formated
    supplier_price.nil? ? "" : Order.format_price(supplier_price)
  end
end
