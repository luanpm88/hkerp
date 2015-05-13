class ProductPrice < ActiveRecord::Base
  validates :supplier_id, presence: true
  validates :supplier_price, presence: true
  validates :price, presence: true
  
  belongs_to :product
  belongs_to :supplier, :class_name => "Contact"
  belongs_to :customer, :class_name => "Contact"
  
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
  
  def supplier_name
    supplier.nil? ? "" : supplier.name
  end
  
  def customer_name
    customer.nil? ? "" : customer.name
  end
  
  def self.calculate_price(supplier_price)
    price = 0
    if supplier_price < 500000.00
      price = supplier_price + 50000.00
    elsif supplier_price < 1000000.00
      price = supplier_price + 100000.00
    elsif
      price = supplier_price*1.2
    end
    
    return price
  end
  
  def calculate_price
    if !self.price.present? || self.price.to_f == 0.00
      self.price = ProductPrice.calculate_price(self.supplier_price)
    end
  end
end
