class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, :class_name => "User"
  
  def normal
  end
  
  def self.send_notification(current_user, type, item)   
    case type
    when 'order_items_confirmed'
      users = User.joins(:roles)
                  .where(roles: {name: 'purchase_manager'})
      
      if !item.purchase_manager.nil?
        users = users.where(id: item.purchase_manager.id)
      end      
      
      users.each do |user|
        n = Notification.new
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
      end
    when 'order_price_confirmed'
      users = User.where(id: item.salesperson_id)
      
      users.each do |user|
        n = Notification.new
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
      end
    else
    end
  end
  
  def display_title
    case type_name
    when 'order_items_confirmed'
      "New order waiting for price"
    when 'order_price_confirmed'
      "Order price was updated"
    else
    end
  end
  
  def display_description
    case type_name
    when 'order_items_confirmed'
      order = Order.find(item_id)
      order.is_purchase ? order.supplier.name : order.customer.name
    when 'order_price_confirmed'
      order = Order.find(item_id)
      order.is_purchase ? order.supplier.name : order.customer.name
    else
    end
  end
  
  def display_url
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    case type_name
    when 'order_items_confirmed'
      link_helper.url_for({controller: "orders", action: "pricing_orders"})
    when 'order_price_confirmed'
      link_helper.url_for({controller: "orders"})
    else
    end
  end
end
