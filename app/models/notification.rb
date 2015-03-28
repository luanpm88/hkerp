class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, :class_name => "User"
  
  def normal
  end
  
  def self.send_notification(current_user, type, item)
    n = Notification.new
    
    case type
    when 'order_items_confirmed'
      users = User.joins(:roles)
                  .where(roles: {name: 'purchase_manager'})
      
      if !item.purchase_manager.nil?
        users = users.where(id: item.purchase_manager.id)
      end      
      
      users.each do |user|        
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
      end
    when 'order_price_confirmed'
      users = User.where(id: item.salesperson_id)
      
      users.each do |user|
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
      end
    when 'order_confirmed'
      users = User.joins(:roles)
                  .where(roles: {name: 'storage_manager'})
      
      users.each do |user|
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
      end
      
      if !item.is_deposited
        Notification.send_notification(current_user, 'order_not_deposited', item)
      end
      
      if item.is_out_of_stock
        Notification.send_notification(current_user, 'order_out_of_stock', item)
      end      
      
    when 'order_out_of_stock'
      users = User.joins(:roles)
                  .where(roles: {name: 'purchase_manager'})
      
      users.each do |user|
        n.type_name = type
        n.user = user
        n.icon = 'icon-warning-sign'
        n.item_id = item.id
        
        n.save
      end
    
    
    when 'order_not_deposited'
      users = User.joins(:roles)
                  .where(roles: {name: 'accountant'})
      
      users.each do |user|
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
      end
      
      
    else
    end
    
    UserMailer.send_notification(n).deliver
  end
  
  def display_title
    case type_name
    when 'order_items_confirmed'
      "Order waiting for price"
    when 'order_price_confirmed'
      "Order price was updated"
    when 'order_confirmed'
      "Order waiting for delivery"
    when 'order_out_of_stock'
      "Out of stock!"
    when 'order_not_deposited'
      "New Order with Payment!"
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
    when 'order_confirmed'
      order = Order.find(item_id)
      order.is_purchase ? order.supplier.name : order.customer.name
    when 'order_out_of_stock'
      "Product(s) is out of stock."
    when 'order_not_deposited'
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
    when 'order_confirmed'
      order = Order.find(item_id)
      order.is_purchase ? link_helper.url_for({controller: "deliveries", purchase: 1}) : link_helper.url_for({controller: "deliveries", only_path: false})
    when 'order_out_of_stock'
      link_helper.url_for({controller: "orders", action: "pricing_orders"})
    when 'order_not_deposited'
      link_helper.url_for({controller: "accounting", action: "orders"})
    else
    end
  end
  
  def self.sales_delivery_alert
    count = Order.customer_orders
                              .joins(:order_status).where(order_statuses: {name: "confirmed"})
                              .where("delivery_status_name != ?", 'delivered').where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  def self.purchase_delivery_alert
    count = Order.purchase_orders
                              .joins(:order_status).where(order_statuses: {name: "confirmed"})
                              .where("delivery_status_name != ?", 'delivered').where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  def self.delivery_alert
    count = Order
                .joins(:order_status).where(order_statuses: {name: "confirmed"})
                .where("delivery_status_name != ?", 'delivered').where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  def self.price_confirmed_sales_order_alert
    count = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "price_confirmed"}).count
    return count > 0 ? count : ""
  end
  def self.sales_alert
    self.price_confirmed_sales_order_alert
  end
  
  
  def self.items_confirmed_sales_order_alert
    count = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "items_confirmed"}).count
    count += Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "confirmed"})
                  .where("delivery_status_name LIKE ?", '%out_of_stock%').where(parent_id: nil).count
    return count > 0 ? count : ""
  end
  def self.purchase_alert
    self.items_confirmed_sales_order_alert
  end
  
  def self.sales_payment_alert
    count = Order.customer_orders
                .joins(:order_status).where(order_statuses: {name: "confirmed"})
                .where("payment_status_name IN (?,?,?)", 'out_of_date', 'not_deposited', 'pay_back').where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  
  def self.purchase_payment_alert
    count = Order.purchase_orders
                  .joins(:order_status).where(order_statuses: {name: "confirmed"})
                  .where("payment_status_name IN (?,?)", 'out_of_date', 'not_deposited').where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  
  def self.accounting_alert
    self.purchase_payment_alert + self.sales_payment_alert
  end
end
