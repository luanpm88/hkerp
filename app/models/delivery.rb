class Delivery < ActiveRecord::Base
  belongs_to :order
  
  has_many :delivery_details, :dependent => :destroy
  
  validate :valid_delivery_details
  
  def valid_delivery_details
      if order.is_purchase
        delivery_details.each do |item|        
          if item.order_detail.remain_count == 0 || !item.check_valid_serial_numbers
            errors.add(:serial_numbers, "can't be greater than quantity")
          end
        end        
      else
        delivery_details.each do |item|
          product = item.order_detail.product          
          if item.order_detail.remain_count == 0 || product.stock < item.quantity || !item.check_valid_serial_numbers
            errors.add(:serial_numbers, "can't be greater than quantity")
          end
        end       
      end
  end
  
  def update_stock
      if order.is_purchase        
        # save lines and sales delivery
        delivery_details.each do |item|
          product = item.order_detail.product         
          
          product.stock += item.quantity
          product.insert_serial_numbers(item.serial_numbers_extracted)
          
          product.save
        end
      else        
        # save lines and sales delivery
        delivery_details.each do |item|
          product = item.order_detail.product
          
          product.stock -= item.quantity      
          product.remove_serial_numbers(item.serial_numbers_extracted)
          
          product.save
        end
      end
      
    save
    
    return true
  end
  
  def display_name
    created_at.strftime("%Y-%m-%d, %H:%M:%S")
  end
  
  def total
    total = 0;
    delivery_details.each {|item|
      total = total + item.total
    }
    return total
  end
  
  def total_vat
    total = 0
    delivery_details.each {|item|
      total = total + item.total
    }
    return total*(order.tax.rate/100+1)
  end
  
  def vat_amount
    return total*(order.tax.rate/100)
  end
  
  def total_formated
    Order.format_price(total)
  end
  
  def total_vat_formated
    Order.format_price(total_vat)
  end
  
  def vat_amount_formated
    Order.format_price(vat_amount)
  end
  
end
