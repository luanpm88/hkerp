class ProductPrice < ActiveRecord::Base
  #validates :supplier_id, presence: true
  #validates :supplier_price, presence: true
  #validates :price, presence: true

  validate :not_empty_price

  belongs_to :product
  belongs_to :supplier, :class_name => "Contact"
  belongs_to :customer, :class_name => "Contact"

  belongs_to :user

  has_many :product_prices

  after_save :update_product_cache_last_priced

  def update_product_cache_last_priced
    if product.present?
      product.update_cache_last_priced
    end
  end

  def not_empty_price
    if price.to_f == 0.00 && supplier_price.to_f == 0.00 && supplier_id.nil?
       errors.add(:price, "can't be empty")
    end
  end

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
    if supplier_price < 200000.00
      price = supplier_price + 50000.00
    #elsif supplier_price < 1000000.00
    #  price = supplier_price + 100000.00
    else
      price = supplier_price*1.2
    end

    return price
  end

  def calculate_price
    if self.supplier_price.to_f != 0.0
      self.price = ProductPrice.calculate_price(self.supplier_price)
    end
  end

  def supplier_name
    (supplier.present? ? supplier.name : '')
  end
  
  after_save :update_product_cache_price
  def update_product_cache_price
    self.product.update_cache_price if self.product.present?
  end
end
