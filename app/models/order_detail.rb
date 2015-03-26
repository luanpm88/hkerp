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
    Order.format_price(total)
  end
  
  def formated_price
    Order.format_price(price)
  end
  
  def formated_supplier_price
    Order.format_price(supplier_price)
  end
  
  def price=(new_price)
    self[:price] = new_price.to_s.gsub(/\,/, '')
  end
  
  def supplier_price=(new_price)
    self[:supplier_price] = new_price.to_s.gsub(/\,/, '')
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
    
    if order.is_purchase
      if remain_count <= 0
        return '<div class="blue">delivered</div>'      
      else
        return '<div class="green">available</div>'
      end
    end
    
    
    if remain_count == 0
      return '<div class="blue">delivered</div>'    
    elsif remain_count < 0
      return '<div class="orange">waiting for return</div>'
    elsif is_out_of_stock
      return '<div class="red">out_of_stock</div>'
    else
      return '<div class="green">not_delivered</div>'
    end
  end
  
  def is_out_of_stock
    stock = product.stock
    
    return (stock.nil? || stock == 0 || stock < remain_count) && !order.is_purchase
  end
  
  def delivered_count
    total = delivery_details.sum :quantity
    
    find_related_order_details.each do |od|
      od.delivery_details.each do |dd|
        total += dd.quantity
      end
    end
    
    return total
  end
  
  def remain_count
    quantity - delivered_count
  end
  
  def find_related_order_details
    arr = []
    order.get_outdated_orders.each do |o|
      arr << o.order_details.where(product_id: self.product_id).first if !o.order_details.where(product_id: self.product_id).empty?
    end
    
    return arr
  end
  
  def return_count
    return delivered_count - quantity
  end
  
  def out_of_stock_count
    remain_count - product.stock
  end
end
