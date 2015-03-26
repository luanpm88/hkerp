class Delivery < ActiveRecord::Base
  belongs_to :order
  
  has_many :delivery_details, :dependent => :destroy
  
  belongs_to :creator, :class_name => "User"
  belongs_to :delivery_person, :class_name => "User"
  
  validate :delivery_details_not_empty
  validate :valid_serial_numbers
  validate :valid_delivery_details
  
  def delivery_details_not_empty
    if delivery_details.empty?
      errors.add(:delivery_details, "can't be empty")
    end
  end
  
  def valid_serial_numbers
    delivery_details.each do |item|
      if !item.check_valid_serial_numbers
        errors.add(:serial_numbers, "can't be greater than quantity")
      end
    end
  end
  
  def valid_delivery_details
    if order.is_purchase
      delivery_details.each do |item|
        if self.is_return == 1
            if item.order_detail.return_count + item.quantity < 0
              errors.add(:quantity, "can't be greater than redundant items")
            end
        else
            if item.order_detail.remain_count > item.quantity
              errors.add(:quantity, "can't be greater than remain items")
            end
        end
      end        
    else
      delivery_details.each do |item|
        product = item.order_detail.product
        if self.is_return == 1
            if item.order_detail.return_count + item.quantity < 0
              errors.add(:quantity, "can't be greater than redundant items")
            end
        else
            if item.order_detail.remain_count < item.quantity
              errors.add(:quantity, "can't be greater than remain items")
            end
            if product.stock < item.quantity
              errors.add(:quantity, "can't be greater than stock")
            end
        end
      end       
    end
  end
  
  def update_stock
    self.save
    
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
    
    return true
  end
  
  def display_name
    created_at.strftime("%Y-%m-%d, %H:%M")
  end
  
  def total
    total = 0;
    delivery_details.each {|item|
      total = total + item.total
    }
    return total.abs
  end
  
  def total_vat
    total = 0
    delivery_details.each {|item|
      total = total + item.total
    }
    return (total*(order.tax.rate/100+1)).abs
  end
  
  def vat_amount
    return (total*(order.tax.rate/100)).abs
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
  
  def ticket_title
    if is_return == 1
      return "PHIẾU TRẢ HÀNG"
    elsif !order.is_purchase
      return "PHIẾU XUẤT KHO"
    else
      return "PHIẾU NHẬP KHO"
    end
  end
  
  
  
end
