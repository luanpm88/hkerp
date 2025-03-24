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
    end
    
    if user.has_role? "director"
      can :top_buyers, Contact
      can :not_buy_customers, Contact
    end

    if user.has_role? "user"
      if user.ATT_No.present?
        can :view_attendance, Checkinout
      end
      can :read_notification, Notification

      can :read, User

      can :read, Contact
      can :datatable, Contact
      can :create, Contact
      can :update, Contact do |contact|
        contact.user_id == user.id
      end
      can :ajax_show, Contact
      can :ajax_new, Contact
      can :ajax_create, Contact
      can :ajax_list_agent, Contact
      can :ajax_list_supplier_agent, Contact
      can :ajax_destroy, Contact do |c|
        c.user_id == user.id && c.contact_types.include?(ContactType.agent) && Order.where("agent_id = ? OR supplier_agent_id = ?", c.id, c.id).count == 0
      end
      can :ajax_edit, Contact do |c|
        c.user_id == user.id && c.contact_types.include?(ContactType.agent) && Order.where("agent_id = ? OR supplier_agent_id = ?", c.id, c.id).count == 0
      end
      can :ajax_update, Contact do |c|
        c.user_id == user.id && c.contact_types.include?(ContactType.agent) && Order.where("agent_id = ? OR supplier_agent_id = ?", c.id, c.id).count == 0
      end

      can :read, Product
      can :create, Product
      can :update, Product do |product|
        product.user_id == user.id
      end

      can :read, Category
      can :create, Category
      #can :update, Category

      can :read, Manufacturer
      can :create, Manufacturer
      #can :update, Manufacturer

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

      can :statistics, CommissionProgram
      can :read, CommissionProgram

      can :read_commissions, Order do |o|
        o.salesperson == user
      end

      can :read, City
      can :read, State
      can :read, Country
      can :select_tag, City

      can :logo, Contact

      can :show, User
      can :avatar, User

      can :update_public_price, Product do |p|
        p.id.nil? || (p.user == user && p.product_price.user == user) || p.product_price.id.nil?
      end

      can :activity_log, User do |u|
        u == user
      end

      can :read, Feedback
      can :datatable, Feedback
      can :create, Feedback
      can :picture, Feedback
      can :update, Feedback do |f|
        f.user_id == user.id
      end
      
      can :warranty_check, Product

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
        order.id.present? && order.is_sales && order.salesperson_id == user.id && ["new","price_confirmed"].include?(order.status.name)
      end
      can :confirm_order, Order do |order|
        order.is_sales && order.salesperson_id == user.id && (["price_confirmed"].include?(order.status.name) || (!order.is_prices_oudated && ['new','items_confirmed','price_confirmed'].include?(order.status.name)))
      end
      can :cancel_order, Order do |order|
        order.is_sales && order.salesperson_id == user.id && ['items_confirmed','price_confirmed','confirmed','finished'].include?(order.status.name)
      end
      can :change, Order do |order|
        order.is_sales && order.salesperson_id == user.id && ['price_confirmed','confirmed'].include?(order.status.name)
      end
      can :do_change, Order do |order|
        order.is_sales && order.salesperson_id == user.id && ['price_confirmed','confirmed'].include?(order.status.name)
      end

      can :update_info, Order do |order|
        order.is_sales && order.salesperson_id == user.id && ['new','items_confirmed','price_confirmed','confirmed'].include?(order.status.name)
      end
      can :do_update_info, Order do |order|
        order.is_sales && order.salesperson_id == user.id && ['new','items_confirmed','price_confirmed','confirmed'].include?(order.status.name)
      end

      can :download_pdf, Order do |order|
        order.is_sales && order.salesperson_id == user.id
      end

      can :create, OrderDetail
      can :read, OrderDetail do |order_detail|
        order_detail.order.salesperson_id == user.id
      end
      can :update, OrderDetail do |order_detail|
        order_detail.order.nil? || (order_detail.order.salesperson_id == user.id && ['new','items_confirmed','price_confirmed','confirmed'].include?(order_detail.order.status.name))
      end
      can :ajax_destroy, OrderDetail do |order_detail|
        order_detail.order.nil? || (order_detail.order.salesperson_id == user.id && ['new','items_confirmed','price_confirmed','confirmed'].include?(order_detail.order.status.name))
      end

      can :order_log, Order

      can :company, Contact


      if user.has_role? "company_salesperson"
        can :view_all_customers, Contact        
      end

    end

    if user.has_role? "purchaser"
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
        order.is_sales # && order.status.name == 'items_confirmed' && order.is_price_updated
      end


      can :update_price, Product
      can :quick_update_price, Product
      can :do_update_price, Product
      can :update_public_price, Product

      can :trash, Product do |product|
        product.status == 1 && product.calculated_stock == 0
      end
      can :un_trash, Product do |product|
        product.status == 0
      end
      can :suspend, Product do |product|
        !product.suspended
      end
      can :unsuspend, Product do |product|
        product.suspended
      end

      can :purchase_orders, Order do |order|
        order.purchaser_id == user.id
      end
      can :view_list, Order
      can :create, Order do |order|
        order.is_purchase || order.id.nil?
      end
      can :confirm_order, Order do |order|
        order.is_purchase && order.purchaser_id == user.id && ['new','items_confirmed','price_confirmed'].include?(order.status.name)
      end
      can :update, Order do |order|
        order.is_purchase && order.purchaser_id == user.id && order.status.name == 'new'
      end
      can :destroy, Order do |order|
        order.is_purchase && order.purchaser_id == user.id && ["new"].include?(order.status.name)
      end

      can :change, Order do |order|
        order.is_purchase && order.purchaser_id == user.id && ['confirmed'].include?(order.status.name)
      end
      can :do_change, Order do |order|
        order.is_purchase && order.purchaser_id == user.id && ['confirmed'].include?(order.status.name)
      end
      can :cancel_order, Order do |order|
        order.is_purchase && order.purchaser_id == user.id && ['items_confirmed','price_confirmed','confirmed','finished'].include?(order.status.name)
      end

      can :create, OrderDetail
      can :read, OrderDetail do |order_detail|
        order_detail.order.purchaser_id == user.id
      end
      can :update, OrderDetail do |order_detail|
        order_detail.order.nil? || (order_detail.order.purchaser_id == user.id && order_detail.order.status.name == 'new')
      end
      can :destroy, OrderDetail do |order_detail|
        order_detail.order.nil? || (order_detail.order.purchaser_id == user.id && order_detail.order.status.name == 'new')
      end
      can :ajax_destroy, OrderDetail do |order_detail|
        order_detail.order.nil? || (order_detail.order.purchaser_id == user.id && ['new','confirmed'].include?(order_detail.order.status.name))
      end

      can :view_supplier_price, Product
      can :view_suppliers, Contact

      can :company, Contact
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
        order.is_sales # && order.status.name == 'items_confirmed' && order.is_price_updated
      end

      can :update_price, Product
      can :quick_update_price, Product
      can :do_update_price, Product

      can :trash, Product do |product|
        product.status == 1 && product.calculated_stock == 0
      end
      can :un_trash, Product do |product|
        product.status == 0
      end

      can :purchase_orders, Order
      can :view_list, Order
      can :create, Order do |order|
        order.is_purchase || order.id.nil?
      end
      can :confirm_order, Order do |order|
        order.is_purchase && ['new','items_confirmed','price_confirmed'].include?(order.status.name)
      end
      can :update, Order do |order|
        order.is_purchase && order.status.name == 'new'
      end
      can :destroy, Order do |order|
        order.is_purchase && ["new"].include?(order.status.name)
      end

      can :change, Order do |order|
        order.is_purchase && ['confirmed'].include?(order.status.name)
      end
      can :do_change, Order do |order|
        order.is_purchase && ['confirmed'].include?(order.status.name)
      end

      can :create, OrderDetail
      can :read, OrderDetail
      can :update, OrderDetail do |order_detail|
        order_detail.order.nil? || (order_detail.order.status.name == 'new')
      end
      can :destroy, OrderDetail do |order_detail|
        order_detail.order.nil? || (order_detail.order.status.name == 'new')
      end
      can :ajax_destroy, OrderDetail do |order_detail|
        order_detail.order.nil? || (['new','confirmed'].include?(order_detail.order.status.name))
      end

      can :view_supplier_price, Product
      can :view_suppliers, Contact
      can :statistic_stock, Product

      can :company, Contact
    end

    if user.has_role? "accountant"
      can :read, Order
      can :print_order, Order do |order|
        ['confirmed'].include?(order.status.name)
      end
      can :print_order_fix1, Order
      can :print_order_fix2, Order
      can :print_order_fix3, Order
      can :download_pdf, Order
      can :pay_order, Order  do |order|
        ['canceled','finished','confirmed'].include?(order.status.name) && !order.is_paid
      end

      can :create, PaymentRecord
      can :read, PaymentRecord

      can :pay_tip, Order do |order|
        !order.is_tipped && ['finished'].include?(order.status.name)
      end

      can :pay_commission, Order do |order|
        !order.is_commissioned && ['finished'].include?(order.status.name)
      end

      can :download_pdf, PaymentRecord
      can :download_pdf_2019, PaymentRecord

      can :update_info, Order do |order|
        ['new','items_confirmed','price_confirmed','confirmed'].include?(order.status.name)
      end
      can :do_update_info, Order do |order|
        ['new','items_confirmed','price_confirmed','confirmed'].include?(order.status.name)
      end

      can :finish_order, Order do |order|
        ['confirmed'].include?(order.status.name)
      end

      can :statistic_sales, Order
      can :statistic_purchase, Order

      can :update_tip, Order do |order|
        ['new','items_confirmed','price_confirmed','confirmed','finished'].include?(order.status.name)
      end
      can :do_update_tip, Order do |order|
        ['new','items_confirmed','price_confirmed','confirmed','finished'].include?(order.status.name)
      end

      can :trash, PaymentRecord do |p|
        ['confirmed','finished'].include?(p.order.status.name) && p.accountant_id == user.id
      end

      can :pay_custom, PaymentRecord
      can :do_pay_custom, PaymentRecord

      can :datatable, PaymentRecord
      can :custom_payments, PaymentRecord

      can :destroy, PaymentRecord do |p|
        p.accountant_id == user.id && p.type_name == "custom"
      end
      can :edit_pay_custom, PaymentRecord do |p|
        p.accountant_id == user.id && p.type_name == "custom"
      end
      can :update, PaymentRecord do |p|
        p.accountant_id == user.id && p.type_name == "custom"
      end

      can :statistics, PaymentRecord
      can :cash_book, PaymentRecord
      can :cash_book_xls, PaymentRecord
      can :account_book, PaymentRecord
      can :account_book_xls, PaymentRecord

      can :company, Contact
    end

    if user.has_role? "accountant_manager"
      can :trash, PaymentRecord do |p|
        ['confirmed','finished'].include?(p.order.status.name)
      end
    end

    if user.has_role? "sales_manager"
      can :update, Contact
      can :inactive, Contact

      can :update_info, Order do |order|
        ['new','items_confirmed','price_confirmed','confirmed','finished'].include?(order.status.name)
      end
      can :do_update_info, Order do |order|
        ['new','items_confirmed','price_confirmed','confirmed','finished'].include?(order.status.name)
      end

      can :change, Order do |order|
        order.is_sales && ['price_confirmed','confirmed','finished'].include?(order.status.name)
      end
      can :do_change, Order do |order|
        order.is_sales && ['price_confirmed','confirmed','finished'].include?(order.status.name)
      end
      can :confirm_order, Order do |order|
        order.is_sales && (["price_confirmed"].include?(order.status.name) || (!order.is_prices_oudated && ['new','items_confirmed','price_confirmed','canceled'].include?(order.status.name)))
      end
      can :confirm_items, Order do |order|
        order.is_sales && ["canceled"].include?(order.status.name)
      end
      can :update, Order do |order|
        order.is_sales && ["canceled"].include?(order.status.name)
      end
      can :confirm_items, Order do |order|
        order.id.present? && order.is_sales && ["new","price_confirmed"].include?(order.status.name)
      end
      can :cancel_order, Order do |order|
        order.is_sales && ['items_confirmed','price_confirmed','confirmed','finished'].include?(order.status.name)
      end
      can :update, Order do |order|
        true
      end

      can :create, OrderDetail
      can :read, OrderDetail
      can :update, OrderDetail do |order_detail|
        ['new','confirmed','finished'].include?(order_detail.order.status.name)
      end
      can :ajax_destroy, OrderDetail do |order_detail|
        ['new','confirmed','finished'].include?(order_detail.order.status.name)
      end

      can :view_all_sales_orders, Order

      can :update, CommissionProgram do |cp|
        cp.user == user
      end

      can :create, CommissionProgram
      can :start, CommissionProgram
      can :stop, CommissionProgram

      can :manage, CommissionProgram

      can :view_all_customers, Contact
    end

    if user.has_role? "storage_manager"
      can :create, Delivery
      can :read, Delivery

      can :update, Product

      can :update, Category
      can :update, Manufacturer

      can :download_pdf, Delivery

      can :create, Combination

      can :create, ProductStockUpdate

      can :deliver, Order  do |order|
        ['canceled','confirmed','finished'].include?(order.status.name) && !order.is_delivered?
      end

      can :trash, Delivery do |d|
        ['confirmed','finished'].include?(d.order.status.name) && d.creator_id == user.id
      end

      can :statistics, Product
      can :ajax_product_prices, Product
      can :product_log, Product

      can :combine_parts, Product do |product|
        product.is_combinable
      end
      can :de_combine_parts, Product do |product|
        product.calculated_stock > 0 && product.parts.count > 0
      end

      can :warranty_check, Product
      can :export, Product

      can :view_all_sales_orders, Order
      
      can :refresh_price, Product
      can :suspend, Product
      can :unsuspend, Product
    end

  end
end
