class SalesDelivery < ActiveRecord::Base
  belongs_to :order
  
  has_many :sales_delivery_details, :dependent => :destroy
  
  def update_stock
    count = 0
    # check if valid line info
    sales_delivery_details.each do |item|
      product = item.order_detail.product
      
      if item.order_detail.remain_count == 0 || product.stock < item.quantity
        return false
      end
      
       count += 1
    end
    
    # check if no line item
    if count == 0
      return false
    end
    
    
    # save lines and sales delivery
    sales_delivery_details.each do |item|
      product = item.order_detail.product
      product.stock -= item.quantity
      product.save
    end
    
    save
    
    return true
  end
end
