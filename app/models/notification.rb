class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, :class_name => "User"
  
  def normal
  end
  
  def self.send_email(n)
    UserMailer.send_notification(n).deliver
  end
  
  def self.send_notification(current_user, type, item)    
    
    case type
    when 'order_items_confirmed'
      users = User.joins(:roles)
                  .where(roles: {name: 'purchaser'})
      
      if !item.purchaser.nil?
        users = users.where(id: item.purchaser.id)
      end      
      
      users.each do |user|
        n = Notification.new
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
        
        #send_email(n)
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
        
        send_email(n)
      end
    when 'order_confirmed'
      users = User.joins(:roles)
                  .where(roles: {name: 'storage_manager'})
      
      users.each do |user|
        n = Notification.new
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
        
        #send_email(n)
      end
      
      if !item.is_deposited
        send_notification(current_user, 'order_not_deposited', item)
      end
      
      if item.is_out_of_stock
        send_notification(current_user, 'order_out_of_stock', item)
      end      
      
    when 'order_out_of_stock'
      users = User.joins(:roles)
                  .where(roles: {name: 'purchaser'})
      
      users.each do |user|
        n = Notification.new
        n.type_name = type
        n.user = user
        n.icon = 'icon-warning-sign'
        n.item_id = item.id
        
        n.save
        
        #send_email(n)
      end
    
    
    when 'order_not_deposited'
      users = User.joins(:roles)
                  .where(roles: {name: 'accountant'})
      
      users.each do |user|
        n = Notification.new
        n.type_name = type
        n.user = user
        n.sender = current_user
        n.item_id = item.id
        
        n.save
        
        #send_email(n)
      end
      
      
    else
    end
    
    
  end
  
  def display_title
    case type_name
    when 'order_items_confirmed'
      "Order waiting for price"
    when 'order_price_confirmed'
      "Price Confirmed! Order's ready for confirmed"
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
      link_helper.url_for({controller: "orders", action: "pricing_orders", only_path: false})
    when 'order_price_confirmed'
      link_helper.url_for({controller: "orders", only_path: false})
    when 'order_confirmed'
      order = Order.find(item_id)
      order.is_purchase ? link_helper.url_for({controller: "deliveries", purchase: 1, only_path: false}) : link_helper.url_for({controller: "deliveries", only_path: false})
    when 'order_out_of_stock'
      link_helper.url_for({controller: "orders", action: "pricing_orders", only_path: false})
    when 'order_not_deposited'
      link_helper.url_for({controller: "accounting", action: "orders", only_path: false})
    else
    end
  end
  
  def self.sales_delivery_alert(user=nil)
    count = Order.customer_orders
                              .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]})
                              .where("delivery_status_name LIKE ? OR delivery_status_name LIKE ?", '%not_delivered%', '%return_back%')
                              .where(parent_id: nil).count("orders.id")
    
    return count > 0 ? count : ""
  end
  def self.purchase_delivery_alert(user=nil)
    count = Order.purchase_orders
                              .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]})
                              .where("delivery_status_name LIKE ? OR delivery_status_name LIKE ?", '%not_delivered%', '%return_back%')
                              .where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  def self.delivery_alert(user=nil)
    count = Order
                .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]})
                .where("delivery_status_name LIKE ? OR delivery_status_name LIKE ?", '%not_delivered%', '%return_back%')
                .where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  def self.price_confirmed_sales_order_alert(user)
    orders = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "price_confirmed"})
    if !user.can?(:view_all_sales_orders, Order)
      orders = orders.where(salesperson_id: user.id)
    end
    
    count = orders.count
    return count > 0 ? count : ""
  end
  def self.sales_alert(user)
    self.price_confirmed_sales_order_alert(user)
  end
  
  
  def self.items_confirmed_sales_order_alert(user=nil)
    count = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "items_confirmed"}).count
    count += Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]})
                  .where("delivery_status_name LIKE ?", '%out_of_stock%').where(parent_id: nil).count
    return count > 0 ? count : ""
  end
  def self.purchase_alert(user=nil)
    self.items_confirmed_sales_order_alert
  end
  
  def self.sales_payment_alert(user=nil)
    count = Order.customer_orders
                .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]})
                .where("payment_status_name IN (?,?,?)", 'out_of_date', 'not_deposited', 'pay_back').where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  
  def self.purchase_payment_alert
    count = Order.purchase_orders
                  .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]})
                  .where("payment_status_name IN (?,?,?)", 'out_of_date', 'not_deposited', 'pay_back').where(parent_id: nil).count
    
    return count > 0 ? count : ""
  end
  
  def self.accounting_alert
    count = self.purchase_payment_alert.to_i + self.sales_payment_alert.to_i
    return count > 0 ? count : ""
  end
  
  
end
