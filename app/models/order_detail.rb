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
  belongs_to :product_price
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
  
  def total_vat
    sum = self.total*(order.tax.rate/100+1)
    if !discount_amount.nil?
      sum -= discount_amount
    end
    return sum
  end
  
  def total_vat_formated
    Order.format_price(total_vat)
  end
  
  def vat_amount
    price*(order.tax.rate/100)
  end
  
  def vat_amount_formated
    Order.format_price(vat_amount)
  end
  
  def formated_supplier_price
    Order.format_price(supplier_price)
  end
  
  def price=(new_price)
    self[:price] = new_price.to_s.gsub(/\,/, '')
  end
  def quantity=(number)
    self[:quantity] = number.to_s.gsub(/\,/, '')
  end
  
  def supplier_price=(new_price)
    self[:supplier_price] = new_price.to_s.gsub(/\,/, '')
  end
  
  def max_delivery
    stock = product.calculated_stock
    
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
    str = ""
    
    if order.is_purchase
      if remain_count <= 0
        str ='delivered'      
      else
        str ='available'
      end
    end
    
    if quantity == 0
      str ='canceled'
    elsif remain_count == 0
      str ='delivered'
    elsif remain_count < 0
      str ='waiting_for_return'
    elsif is_out_of_stock
      str ='out_of_stock'
    else
      str ='not_delivered'
    end
    
    return "<div class=\"#{str}\">#{str}</div>"
  end
  
  def is_out_of_stock
    stock = product.calculated_stock
    
    return (stock.nil? || stock < remain_count) && !order.is_purchase
  end
  
  def is_combinable
    product.is_combinable
  end
  
  def delivered_count
    delivery_details.joins(:delivery).where(deliveries: {status: 1}).sum :quantity
  end
  
  def remain_count
    quantity - delivered_count
  end  
    
  def return_count
    return delivered_count - quantity
  end
  
  def out_of_stock_count
    remain_count - product.calculated_stock
  end
  
  def cost
    !product_price.nil? ? product_price.supplier_price : 0
  end
  def cost_formated
    Order.format_price(cost)
  end
  
  def cost_vat
    cost*(order.tax.rate/100+1)
  end
  def cost_vat_formated
    Order.format_price(cost_vat)
  end
  
  def cost_total
    cost*quantity
  end
  def cost_total_formated
    Order.format_price(cost_total)
  end
  
  def cost_total_vat
    cost_total*(order.tax.rate/100+1)
  end
  def cost_total_vat_formated
    Order.format_price(cost_total_vat)
  end
  
  def fare
    result = total - cost_total
    result -= tip_amount if tip_amount.present?
    
    return result
  end
  
  def fare_vat
    fare - fare*(0.25)
  end
  
  def fare_formated
    Order.format_price(fare)
  end
  
  def paid_status
    status = ""
    if order.is_paid
      status = "paid"
    else
      status = "not_paid"
    end
    
    return "<div class=\"#{status}\">#{status}</div>".html_safe
  end
  
  def discount_amount=(new_price)
    self[:discount_amount] = new_price.to_s.gsub(/\,/, '')
  end
  
  def tip_amount=(new_price)
    self[:tip_amount] = new_price.to_s.gsub(/\,/, '')
  end
  
  def update_price(user)
    params = {}
    if order.is_purchase
      params[:price] = product.product_price.price.nil? ? 0 : product.product_price.price
      params[:supplier_id] = order.supplier_id
      params[:supplier_price] = self.price
      params[:customer_id] = nil
    else
      #params[:price] = self.price
      #params[:supplier_id] = product.product_price.supplier_id
      #params[:supplier_price] = product.product_price.supplier_price
      #params[:customer_id] = order.customer_id
    end
    product.update_price(params,user)
    
  end
  
  def is_price_outdated
    if product.is_price_outdated # || (product.product_price.present? && product.product_price.supplier_price >= self.price)
      return true
    else
      return false
    end
    
  end
  
  def discount_amount_formated
    Order.format_price(discount_amount)
  end
  
  def auto_tip_amount
    amount = (self.total/order.total)*order.tip_amount
    self.update_attribute("tip_amount", amount)
  end

end
