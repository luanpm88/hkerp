class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    # Handle the case where we don't have a current_user i.e. the user is a guest
    user ||= User.new

    # Define a few sample abilities
    # cannot :destroy, Contact
    # cannot :manage , Comment
    # can    :read   , Tag , released: true
    
    #can :manage, Order, :salesperson_id => user.id
    #can :manage, SupplierOrder, :salesperson_id => user.id
    
    if user.has_role? "admin"
      can :manage, :all
    else
      can :read_notification, Notification
      
      can :read, User
      
      can :read, Contact
      can :create, Contact
      can :update, Contact #do |contact|
      #  contact.user_id == user.id
      #end
      can :ajax_show, Contact
      can :ajax_new, Contact
      can :ajax_create, Contact
      can :ajax_list_agent, Contact
      can :ajax_list_supplier_agent, Contact
      can :ajax_destroy, Contact do |c|
        c.contact_type.name == 'Agent' && Order.where("agent_id = ? OR supplier_agent_id = ?", c.id, c.id).count == 0
      end
      
      can :read, Product
      can :create, Product
      can :update, Product #do |product|
      #  product.user_id == user.id
      #end
      
      can :read, Category
      can :create, Category
      can :update, Category
      
      can :read, Manufacturer
      can :create, Manufacturer
      can :update, Manufacturer
      
      # ATTANCENCE == permissions for personal attandence requests
      can :read, Checkinout
      can :read_attendances, User do |u|
        u.id == user.id || user.has_role?("attendance_manager")
      end
      
      can :create, CheckinoutRequest
      can :read, CheckinoutRequest do |request|
        request.user_id == user.id
      end
      can :destroy, CheckinoutRequest do |request|
        request.user_id == user.id && request.status == 0
      end
      can :update, CheckinoutRequest do |request|
        request.user_id == user.id && request.status == 0
      end
      
      if user.has_role? "attendance_manager"
        can :manage, Checkinout
        can :manage, CheckinoutRequest
      end
      
      if user.has_role? "salesperson"
        can :create, Order do |order|
          order.is_sales || order.id.nil?
        end
        can :view_list, Order
        can :read, Order do |order|
          order.is_sales && order.salesperson_id == user.id
        end
        can :update, Order do |order|
          order.is_sales && order.salesperson_id == user.id && ["new"].include?(order.status.name)
        end
        can :destroy, Order do |order|
          order.is_sales && order.salesperson_id == user.id && ["new"].include?(order.status.name)
        end
        can :confirm_items, Order do |order|
          order.is_sales && order.salesperson_id == user.id && ["new"].include?(order.status.name)
        end
        can :confirm_order, Order do |order|
          order.is_sales && order.salesperson_id == user.id && (["price_confirmed"].include?(order.status.name) || (!order.is_prices_oudated && ['new','items_confirmed','price_confirmed'].include?(order.status.name)))
                            
        end        
        can :change, Order do |order|
          order.is_sales && ['price_confirmed','confirmed'].include?(order.status.name)
        end
        can :do_change, Order do |order|
          order.is_sales && ['price_confirmed','confirmed'].include?(order.status.name)
        end
        
        can :update_info, Order do |order|
          order.is_sales && order.salesperson_id == user.id && ['new','items_confirmed','price_confirmed','confirmed'].include?(order.status.name)
        end
        can :do_update_info, Order do |order|
          order.is_sales && order.salesperson_id == user.id && ['new','items_confirmed','price_confirmed','confirmed'].include?(order.status.name)
        end

        #can :print_order, Order do |order|
        #  order.salesperson_id == user.id && order.status.name == 'confirmed'
        #end
        can :download_pdf, Order do |order|
          order.is_sales && order.salesperson_id == user.id
        end        
        #can :purchase_orders, Order do |order|
        #  order.salesperson_id == user.id
        #end

        can :create, OrderDetail
        can :read, OrderDetail do |order_detail|
          order_detail.order.salesperson_id == user.id
        end
        can :update, OrderDetail do |order_detail|
          order_detail.order.nil? || (order_detail.order.salesperson_id == user.id && ['new','confirmed'].include?(order_detail.order.status.name))
        end
        can :ajax_destroy, OrderDetail do |order_detail|
          order_detail.order.nil? || (order_detail.order.salesperson_id == user.id && ['new','confirmed'].include?(order_detail.order.status.name))
        end        
      end

      if user.has_role? "purchase_manager"        
        can :show, Order
        can :pricing_orders, Order do |order|
          order.is_sales && order.status.name == 'items_confirmed'
        end
        can :update_price, Order do |order|
          order.is_sales && order.status.name == 'items_confirmed'
        end
        can :do_update_price, Order do |order|
          order.is_sales && order.status.name == 'items_confirmed'
        end
        can :confirm_price, Order do |order|
          order.is_sales && order.status.name == 'items_confirmed' && order.is_price_updated
        end

        can :update_price, Product
        can :do_update_price, Product

        can :purchase_orders, Order do |order|
          order.purchase_manager_id == user.id
        end
        can :view_list, Order
        can :create, Order do |order|
          order.is_purchase || order.id.nil?
        end
        can :confirm_order, Order do |order|
          order.is_purchase && order.purchase_manager_id == user.id && ['new','items_confirmed','price_confirmed'].include?(order.status.name)
        end
        can :update, Order do |order|
          order.is_purchase && order.purchase_manager_id == user.id && order.status.name == 'new'
        end
        
        can :change, Order do |order|
          order.is_purchase && order.purchase_manager_id == user.id && ['confirmed'].include?(order.status.name)
        end
        can :do_change, Order do |order|
          order.is_purchase && order.purchase_manager_id == user.id && ['confirmed'].include?(order.status.name)
        end

        can :create, OrderDetail
        can :read, OrderDetail do |order_detail|
          order_detail.order.purchase_manager_id == user.id
        end
        can :update, OrderDetail do |order_detail|
          order_detail.order.nil? || (order_detail.order.purchase_manager_id == user.id && order_detail.order.status.name == 'new')
        end
        can :destroy, OrderDetail do |order_detail|
          order_detail.order.nil? || (order_detail.order.purchase_manager_id == user.id && order_detail.order.status.name == 'new')
        end
      end

      if user.has_role? "accountant"
        can :read, Order
        can :print_order, Order do |order|
          ['confirmed'].include?(order.status.name)
        end
        can :download_pdf, Order
        can :pay_order, Order  do |order|
          ['confirmed'].include?(order.status.name) && !order.is_paid
        end
        
        can :create, PaymentRecord
        can :read, PaymentRecord
        
        can :download_pdf, PaymentRecord
        
        can :update_info, Order do |order|
          ['new','items_confirmed','price_confirmed','confirmed'].include?(order.status.name)
        end
        can :do_update_info, Order do |order|
          ['new','items_confirmed','price_confirmed','confirmed'].include?(order.status.name)
        end
        
        can :finish_order, Order do |order|
          ['confirmed'].include?(order.status.name)
        end
      end

      if user.has_role? "storage_manager"
        can :create, Delivery
        can :read, Delivery
        can :deliver, Delivery
        #can :update, Delivery
        
        can :download_pdf, Delivery
        
        can :create, Combination
        
        can :create, ProductStockUpdate
        
        can :deliver, Order  do |order|
          ['confirmed'].include?(order.status.name) && !order.is_delivered?
        end
      end

    end

  end
end
