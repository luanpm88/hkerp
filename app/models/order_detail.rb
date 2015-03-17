class OrderDetail < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  validates :product_id, presence: true
  #validates :supplier_id, presence: true
  validates :unit, presence: true
  #validates :supplier_price, presence: true
  validates :price, presence: true
  validates :warranty, presence: true
  validates :quantity, presence: true
  
  belongs_to :order
  belongs_to :product
  belongs_to :supplier, :class_name => "Contact"
  
  has_many :sales_delivery_details
  
  has_many :delivery_details
  
  def total
    price * quantity
  end
  
  def formated_total
    number_to_currency(total, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_price
    number_to_currency(price, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_supplier_price
    number_to_currency(supplier_price, precision: 0, unit: '', delimiter: ".")
  end
  
  def price=(new_price)
    self[:price] = new_price.gsub(/\,/, '')
  end
  
  def supplier_price=(new_price)
    self[:supplier_price] = new_price.gsub(/\,/, '')
  end
  
  def max_delivery
    stock = product.stock
    
    if order.is_purchase
      return remain_count
    end
    
   
    if stock.nil? || stock == 0 || remain_count <= 0
      return 0
    elsif stock > remain_count
      return remain_count
    else
      return stock
    end
  end
  
  def stock_status
    stock = product.stock
    
    if order.is_purchase
      if remain_count <= 0
        return '<div class="blue">delivered</div>'      
      else
        return '<div class="green">available</div>'
      end
    end
    
    
    if remain_count <= 0
      return '<div class="blue">delivered</div>'
    elsif stock.nil? || stock == 0
      return '<div class="red">unavailable</div>'
    elsif stock >= remain_count
      return '<div class="green">available</div>'
    else
      return '<div class="orange">not enough</div>'
    end
  end
  
  def delivered_count
    delivery_details.sum :quantity
  end
  
  def remain_count
    quantity - delivered_count
  end
end
