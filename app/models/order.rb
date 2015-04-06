class Order < ActiveRecord::Base
  include PgSearch
  
  attr_accessor :debt_days

  validates :supplier_id, presence: true
  validates :customer_id, presence: true
  validates :order_date, presence: true
  validates :order_deadline, presence: true
  validate :valid_debt_date
  
  belongs_to :customer, :class_name => "Contact"
  belongs_to :supplier, :class_name => "Contact"
  belongs_to :tax
  belongs_to :payment_method
  belongs_to :salesperson, :class_name => "User"
  belongs_to :purchase_manager, :class_name => "User"
  
  has_many :order_details, :dependent => :destroy
  
  has_many :drafts, class_name: "Order", foreign_key: "parent_id", :dependent => :destroy
  belongs_to :parent, class_name: "Order"
  
  has_and_belongs_to_many :order_statuses
  
  belongs_to :order_status
  
  has_many :sales_deliveries, :dependent => :destroy
  
  has_many :deliveries, :dependent => :destroy
  
  has_many :payment_records, :dependent => :destroy

  before_save :calculate_discount
  
  def valid_debt_date
    if !deposit.nil? && deposit < 100 && !debt_date.nil?
        if debt_date <= order_date
            errors.add(:debt_date, "can't be smaller than order date")
        end
        
    end    
  end
  
  def total
    total = 0;
    order_details.each {|item|
      total = total + item.total
    }
    return total
  end
  
  def total_vat
    total = 0
    order_details.each {|item|
      total = total + item.total
    }
    return total*(tax.rate/100+1)
  end
  
  def vat_amount
    return total*(tax.rate/100)
  end
  
  def self.format_price(amount)
    return ApplicationController.helpers.format_price(amount)
  end
  
  def formated_total
    Order.format_price(total)
  end
  
  def formated_total_vat
    Order.format_price(total_vat)
  end
  
  def formated_vat_amount
    Order.format_price(vat_amount)
  end
  
  def formated_warranty_cost
    Order.format_price(warranty_cost)
  end
  
  def warranty_cost=(new_warranty_cost)
    self[:warranty_cost] = new_warranty_cost.gsub(/\,/, '')
  end
  
  def create_quotation_code
    lastest = Order.where("order_date::text LIKE :val", :val => order_date.strftime("%Y")+"-"+order_date.strftime("%m")+"%").order("quotation_code DESC").first
    
    if !lastest.nil? && !lastest.quotation_code.nil?
      num = lastest.quotation_code.split(/\-/).last.to_i + 1
      self.quotation_code = "HK-"+order_date.strftime("%Y")+order_date.strftime("%m")+"-"+num.to_s.rjust(3, '0')
    else
      self.quotation_code = "HK-"+order_date.strftime("%Y")+order_date.strftime("%m")+"-"+1.to_s.rjust(3, '0')
    end
  end
  
  def clone_order
    new_order = self.dup
    new_order.order_details << self.order_details.collect { |item| item.dup }
    
    return new_order
  end
  
  def new_order_history
    new_order = self.clone_order
    new_order.older = self
    
    new_order.create_quotation_code
    
    new_order.save
    
    return new_order
  end
  
  def order_history_lines_
    arr = []
    current = self
    arr << current
    while !(current = current.older).nil?
      arr << current
    end
    
    current = self.newer
    if !current.nil?
      arr.unshift(current)
      while !(current = current.newer).nil?
        arr.unshift(current)
      end
    end
    
    return arr
  end
  
  def order_history_lines
    arr = []
    parent = self.parent.nil? ? self : self.parent
    arr << parent
    
    parent.drafts.order("created_at DESC").each do |o|
      arr << o
    end
    
    return arr
  end
  
  @@mangso = ["không","một","hai","ba","bốn","năm","sáu","bảy","tám","chín"]
  def dochangchuc(so,daydu)
    chuoi = ""
    chuc = (so/10).to_i
    donvi = so%10
    
    if chuc > 1
      chuoi = " " + @@mangso[chuc] + " mươi";
      if donvi == 1
        chuoi += " mốt"
      end
    elsif chuc==1
      chuoi = " mười"
      if donvi==1
        chuoi += " một"
      end
    elsif daydu && donvi>0
      chuoi = " lẻ"
    end
    
    if donvi==5 && chuc>1
      chuoi += " lăm"
    elsif donvi>1 || ($donvi==1 && chuc==0)
        chuoi += " " + @@mangso[donvi]
    end
    return chuoi
  end
  
  def docblock(so,daydu)
    chuoi = ""
    tram = (so/100).floor
    so = so%100
    if daydu || tram>0
      chuoi = " " + @@mangso[tram] + " trăm"
      chuoi += dochangchuc(so,true)
    else
      chuoi = dochangchuc(so,false)
    end
    return chuoi;
  end
  
  def dochangtrieu(so,daydu)
    chuoi = ""
    trieu = (so/1000000).floor
    so = so%1000000
    if trieu>0
      
      chuoi = docblock(trieu,daydu) + " triệu"
      daydu = true
    end
    nghin = (so/1000).floor
    so = so%1000;
    if nghin>0
        chuoi += docblock(nghin,daydu) + " nghìn";
        daydu = true;
    end
    if so>0
        chuoi += docblock(so,daydu)
    end
    return chuoi
  end
    
  def docso(so)
    return @@mangso[0] if so==0 
    chuoi = ""
    hauto = ""
    begin
      ty = so%1000000000
      so = (so/1000000000).floor
      if so>0
        chuoi = dochangtrieu(ty,true) + hauto + chuoi
      else
        chuoi = dochangtrieu(ty,false) + hauto + chuoi
      end
      hauto = " tỷ"
    end while so>0
    
    chuoi = chuoi.strip.capitalize
    chuoi = (chuoi =~ /Triệu /) == 0 ? "Một " + chuoi : chuoi
    
    return chuoi.strip.capitalize + " đồng"
  end
  
  def status
    if self.order_status.nil?      
      return self.set_status('new')      
    end
    
    update_attributes(order_status_name: self.order_status.name) if self.order_status.name != self.order_status_name
    
    return self.order_status
  end
  
  def status_formatted
    if self.status.nil?
    else
      self.status.description
    end
  end
  
  def set_status(name)
    status = OrderStatus.where(name: name).first
    if status.nil?
      return false
    else
      self.order_statuses << status
      self.order_status = status
      self.save
    end
    
    return status
  end
  
  def last_updated
    if self.status.nil?
      return self.updated_at
    else
      self.status.updated_at
    end    
  end
  
  def last_updated_formatted
    self.last_updated.strftime("%Y-%m-%d, %H:%M")
  end
  
  def order_date_formatted
    self.order_date.strftime("%Y-%m-%d")
  end
  
  def confirm_order
    if order_details.count == 0
      return false
    end
    
    self.set_status('confirmed')
    Notification.send_notification(salesperson, 'order_confirmed', self)
    
    return true
  end
  
  def finish_order
    if !printed_order_number.present?
      return false
    end
    
    self.set_status('finished')
    
    return true
  end
  
  def confirm_items
    if order_details.count == 0
      return false
    end
    
    self.set_status('items_confirmed')
    Notification.send_notification(salesperson, 'order_items_confirmed', self)
    
    return true
  end
  
  def self.customer_orders
    order("order_date DESC").where("supplier_id="+Contact.HK.id.to_s)
      .where(parent_id: nil)
  end
  
  def self.purchase_orders
    order("order_date DESC").where("customer_id="+Contact.HK.id.to_s)
      .where(parent_id: nil)
  end
  
  def is_purchase
    return self.customer == Contact.HK
  end
  
  def is_sales
    return self.supplier == Contact.HK
  end
  
  def self.statistics(year, month=nil)
    status = OrderStatus.get("confirmed")
    
    total_buy = 0.00
    total_sell = 0.00
    total_buy_with_vat = 0.00
    total_sell_with_vat = 0.00
    total_vat_buy = 0.00
    total_vat_sell = 0.00
    payment_paid = 0.00
    payment_paid_vat = 0.00
    payment_recieved = 0.00
    payment_recieved_vat = 0.00
    payment_vat_paid = 0.00
    payment_vat_recieved = 0.00
    
    sell_orders = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "finished"})
                  .where('extract(year from order_date) = ?', year)
    if month.present?
      sell_orders = sell_orders.where('extract(month from order_date) = ?', month) 
    end
                  
        
    sell_orders.each do |order|
      if order.parent.nil?
        total_sell += order.total
        total_sell_with_vat += order.total_vat
        total_vat_sell += order.vat_amount
        
        payment_recieved_vat += order.paid_amount
        payment_recieved += order.paid_amount/(order.tax.rate/100+1)
        payment_vat_recieved += order.paid_amount*(order.tax.rate/100)
      end      
    end
    
    buy_orders = Order.purchase_orders
                  .joins(:order_status).where(order_statuses: {name: "finished"})
                  .where('extract(year from order_date) = ?', year)
    if month.present?
      buy_orders = buy_orders.where('extract(month from order_date) = ?', month) 
    end
        
    buy_orders.each do |order|
      if order.parent.nil?
        total_buy += order.total
        total_buy_with_vat += order.total_vat
        total_vat_buy += order.vat_amount
        
        payment_paid_vat += order.paid_amount
        payment_paid += order.paid_amount/(order.tax.rate/100+1)
        payment_vat_paid += order.paid_amount*(order.tax.rate/100)
      end      
    end
    
    return {
      total_buy: format_price(total_buy),
      total_sell: format_price(total_sell),
      total_buy_with_vat: format_price(total_buy_with_vat),
      total_sell_with_vat: format_price(total_sell_with_vat),
      total_vat_buy: format_price(total_vat_buy),
      total_vat_sell: format_price(total_vat_sell),
      
      payment_paid_vat: format_price(payment_paid_vat),
      payment_paid: format_price(payment_paid),
      payment_vat_paid: format_price(payment_vat_paid),
      payment_recieved_vat: format_price(payment_recieved_vat),
      payment_recieved: format_price(payment_recieved),
      payment_vat_recieved: format_price(payment_vat_recieved),
      
      sell_orders: sell_orders,
      buy_orders: buy_orders
    }
  end
  
  def self.delivery_sales_orders
    Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "confirmed"}) # orders confirmed
  end
  
  def self.delivery_purchase_orders
    Order.purchase_orders
                  .joins(:order_status).where(order_statuses: {name: "confirmed"}) # orders confirmed
  end
  
  def self.accounting_sales_orders
    Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]}) # orders confirmed
  end
  
  def self.accounting_purchase_orders
    Order.purchase_orders
                  .joins(:order_status).where(order_statuses: {name: ["confirmed","finished"]}) # orders confirmed
  end
  
  pg_search_scope :search,
                against: [:order_status_name, :delivery_status_name, :quotation_code, :buyer_company, :buyer_name, :buyer_tax_code, :buyer_address, :buyer_email],
                associated_against: {
                  salesperson: [:first_name],
                  purchase_manager: [:first_name],
                  supplier: [:name, :tax_code, :address, :email],
                  order_details: [:product_name, :product_description],
                  #order_status: [:name]
                },
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
        when "1"
          order = "categories.name"
        when "2"
          order = "manufacturers.name"
        when "3"
          order = "products.name"
        when "4"
          order = "products.price"
        else
          order = "orders.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "created_at DESC"
    end
    
    where = {}    
    where[:customer_id] = params["customer_id"] if params["customer_id"].present?
    where[:supplier_id] = params["supplier_id"] if params["supplier_id"].present?
    #where[:salesperson_id] = user.id
    
    if params[:page].present? && params[:page] == "accounting"
      if params[:purchase]
        @items = self.accounting_purchase_orders
      else
        @items = self.accounting_sales_orders
      end
    elsif params[:page].present? && params[:page] == "delivery"
      if params[:purchase]
        @items = self.delivery_purchase_orders
      else
        @items = self.delivery_sales_orders
      end
    else
      if params[:purchase]
        @items = self.purchase_orders
      else
        @items = self.customer_orders
      end
    end
    
    @items = @items.joins(:order_status).where(order_statuses: {name: params["order_status"]}) if params["order_status"].present?
    @items = @items.where('extract(year from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["year"]) if params["year"].present?
    @items = @items.where('extract(month from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["month"]) if params["month"].present?
    @items = @items.where('extract(day from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["day"]) if params["day"].present?
    
    @items = @items.where(where)
    @items = @items.search(params["search"]["value"]) if !params["search"]["value"].empty?    
    @items = @items.order(order) if !order.nil?
    
    total = @items.count(:all)
    
    @items = @items.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 7
    @items.each do |item|
      
      if params[:purchase]
        name_col = item.supplier.short_name
      else
        name_col = item.customer.short_name
      end
      
      puts User.current_user
      
      case params[:page]
      when "delivery"
          row = [
                  item.quotation_code,              
                  link_helper.link_to(name_col, {controller: "orders", action: "show", id: item.id}, class: "fancybox.iframe show_order")+item.display_description,                                
                  "<div class=\"text-center\"><strong>salesperson:</strong><br />#{item.salesperson_name}<br /><strong>purchaser:</strong><br />#{item.purchase_manager_name}</div>",
                  '<div class="text-center">'+item.order_date_formatted+'</div>',
                  '<div class="text-center">'+item.display_status+'</div>',
                  "<div class=\"text-center\">#{item.payment_status}</div>",
                  "<div class=\"text-center\">#{item.delivery_status}<strong>#{item.items_delivered}</strong>/#{item.items_total}</div>",
                  ''
                ]
          data << row
          actions_col = 7
      when "accounting"
          row = [
                  item.quotation_code,              
                  link_helper.link_to(name_col, {controller: "orders", action: "show", id: item.id}, class: "fancybox.iframe show_order")+item.display_description,                                
                  "<div class=\"text-center\"><strong>salesperson:</strong><br />#{item.salesperson_name}<br /><strong>purchaser:</strong><br />#{item.purchase_manager_name}</div>",
                  '<div class="text-center">'+item.order_date_formatted+'</div>',
                  '<div class="text-center">'+item.delivery_status+'</div>',
                  '<div class="text-center">'+item.display_status+'</div>',
                  "<div class=\"text-center\">#{item.payment_status}Paid:<strong>#{item.paid_amount_formated}</strong><br />Total:#{item.formated_total_vat}<br />Remain:#{item.remain_amount_formated}</div>",                                                      
                  ''
                ]
          data << row
          actions_col = 7
      else
          row = [
                  item.quotation_code,              
                  link_helper.link_to(name_col, {controller: "orders", action: "show", id: item.id}, class: "fancybox.iframe show_order")+item.display_description,              
                  '<div class="text-right">'+item.formated_total_vat+'</div>',
                  "<div class=\"text-center\"><strong>salesperson:</strong><br />#{item.salesperson_name}<br /><strong>purchaser:</strong><br />#{item.purchase_manager_name}</div>",
                  '<div class="text-center">'+item.order_date_formatted+'</div>',
                  "<div class=\"text-center\">#{item.price_status}#{item.delivery_status}</div>",                  
                  '<div class="text-center">'+item.display_status+'</div>',
                  ''
                ]
          data << row
          actions_col = 7
      end
          
    end
    
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @items, actions_col: actions_col}
  end
  
  def items_total
    order_details.sum :quantity
  end
  
  def items_delivered
    total = 0
    order_details.each do |line|
      total += line.delivered_count
    end
    
    return total
  end
  
  def items_delivery_remain
    items_total - items_delivered
  end
  
  def is_combinable
    order_details.each do |od|
      if od.is_combinable
        return true
      end      
    end
    return false
  end
  
  def delivery_status
    status_arr = []
    if ['confirmed','finished'].include?(status.name)      
      if is_delivered?
        status_arr << 'delivered'
      else
        if has_return_items
          status_arr << 'return_back'
        end
        if has_delvery_items
          status_arr << 'not_delivered'
        end
        if is_out_of_stock
          status_arr << 'out_of_stock'
        end
        if is_combinable
          status_arr << 'combinable'
        end
      end
    end
    
    update_attributes(delivery_status_name: status_arr.join(",")) if status_arr.join(",") != delivery_status_name
    
    str = ""
    status_arr.each do |s|
      str += "<div class=\"#{s}\">#{s}</div>"
    end
    return str.html_safe
  end
  
  def paid_amount
    total = payment_records.sum :amount
  end
  
  def remain_amount
    total_vat - paid_amount
  end
  
  def remain_amount_formated
    Order.format_price(remain_amount)
  end
  
  def paid_amount_formated
    Order.format_price(paid_amount)
  end
  
  def is_paid
    total_vat == paid_amount
  end
  
  def is_payback
    paid_amount > total_vat.round(0)
  end
  
  
  def payment_status
    status = ""
    if is_payback
      status = "pay_back"
    elsif paid_amount == total_vat.round(0)
      status = "paid"
    elsif !is_deposited
      status = "not_deposited"
    elsif is_deposited && !debt_date.nil? && debt_date >= order_date
      status = "debt"
    elsif is_deposited && !debt_date.nil? && debt_date < order_date
      status = "out_of_date"
    else
      status = "out_of_date"
    end
    
    update_attributes(payment_status_name: status)
    
    return "<div class=\"#{status}\">#{status}</div>".html_safe
  end
  
  def save_as_new(order_params)
      new_params = order_params.dup
      new_params[:order_detail_ids] = []
      @dup_order = Order.new(new_params)
      
      @dup_order.create_quotation_code
      
      
      @dup_order.supplier = self.supplier
      @dup_order.customer = self.customer      
      
      @dup_order.save
      
      @dup_order.drafts << self
      self.save
      
      self.drafts.each do |o|
        @dup_order.drafts << o
        o.save
      end
      
      if !order_params[:order_detail_ids].nil?        
        order_params[:order_detail_ids].each do |id|
          if self.order_details.map(&:id).include?(id.to_i)
            od = self.order_details.find_by_id(id.to_i).dup
            od.save
            @dup_order.order_details << od
          else
            @dup_order.order_details << OrderDetail.find_by_id(id.to_i)
          end
        end
      end
      
      return @dup_order
  end
  
  def is_delivered?
    # return items_delivered == items_total    
       
    
    order_details.each do |line|
      if line.delivered_count != line.quantity
        return false
      end
    end
    
    return true
  end
  
  def has_return_items
    order_details.each do |line|
      if line.delivered_count > line.quantity
        return true
      end
    end
    
    return false
  end
  
  def has_delvery_items
    order_details.each do |line|
      if line.delivered_count < line.quantity
        return true
      end
    end
    
    return false
  end
  
  def is_out_of_stock
    order_details.each do |line|
      if line.is_out_of_stock
        return true
      end
    end
    
    return false
  end
  
  def display_status
    str = "" 
    if self.status.nil?
    else
      "<div class=\"#{status.name}\">#{status.name}</div>".html_safe
    end
  end
  
  def out_of_stock_details
    str = ""
    
    if is_out_of_stock    
      order_details.each do |od|
        str += '<div>'+od.product_name+'(<strong class="red">-'+od.out_of_stock_count.to_s+'</strong>) '+'</div>' if od.is_out_of_stock
      end
    end
      
    return str.html_safe
  end
  
  def out_of_stock_order_details
    arr = []
    
    if is_out_of_stock    
      order_details.each do |od|
        arr << od if od.is_out_of_stock
      end
    end
      
    return arr
  end
  
  def self.pricing_orders(user)
    orders = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
    
    orders_2 = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "confirmed"})
                  .where("delivery_status_name LIKE ?", '%out_of_stock%')
    
    orders_total = orders + orders_2
    orders_total.sort{|a,b| b[:created_at] <=> a[:created_at]}   
  end
  
  def confirm_price
    order_details.each do |od|
      if (od.product.product_prices.count == 0 || od.product.product_price.price != od.price) && od.quantity > 0
        return false
      end
    end
    
    set_status("price_confirmed")
    Notification.send_notification(purchase_manager, 'order_price_confirmed', self)
    
    return true
  end
  
  def purchase_manager_name
    purchase_manager.nil? ? "" : purchase_manager.name
  end
  
  def salesperson_name
    salesperson.nil? ? "" : salesperson.name
  end
  
  def debt_days
    if !debt_date.nil?
      (debt_date.to_date - order_date.to_date).to_i
    else
      Time.now
    end
  end
  
  def debt_date_formated
    if !debt_date.nil?
      debt_date.to_date
    else
      Time.now.to_date
    end
  end
  
  def paid_percent
    ((paid_amount/total_vat)*100).round(2)
  end
  
  def payment_out_of_date
    is_deposited && !debt_date.nil? && debt_date < order_date
  end
  
  def is_deposited
    d = !deposit.nil? ? deposit : 100
    paid_percent >= d
  end
  
  def update_order_details(order_details_params)
    
    if order_details_params.nil?
      return false
    end
    
    # Update current order details
    self.order_details.each do |od|        
      order_details_params.each do |line|
        if line[1][:product_id].to_i == od.product_id
          od.update_attributes(
            product_name: line[1][:product_name],
            product_description: line[1][:product_description],
            unit: line[1][:unit],
            price: line[1][:price],
            quantity: line[1][:quantity],
            warranty: line[1][:warranty]
          )
        end
      end
    end
    
    # Insert new order details
    od_pids = []
    self.order_details.each do |od|
      od_pids << od.product_id
    end
    order_details_params.each do |line|
      if !od_pids.include?(line[1][:product_id].to_i)
        self.order_details.create(line[1])
      end
    end
  end
  
  def update_order_details_info(order_details_params)
    
    if order_details_params.nil?
      return false
    end
    
    
    
    # Update current order details
    self.order_details.each do |od|      
      order_details_params.each do |line|
        if line[1][:product_id].to_i == od.product_id
          
          od.update_attributes(
            product_name: line[1][:product_name],
            product_description: line[1][:product_description],
            unit: line[1][:unit],
          )
        end
      end
    end    
  end
  
  def all_deliveries
    deliveries.order("created_at DESC")
  end
  
  def save_draft
    draft = self.dup
    draft.parent_id = self.id

    draft.save
    self.order_details.each do |od|
      draft_od = od.dup
      draft_od.order_id = draft.id
      draft_od.save
    end

    draft.parent = self
    draft.set_status("draft")
  end
  
  def all_payment_records
    payment_records.order("created_at DESC")
  end
  
  def is_prices_oudated
    order_details.each do |od|
      if od.product.is_price_outdated
        return true
      end
    end
    
    return false
  end
  
  def price_status
    status = ""
    if is_prices_oudated
      status = "price_outdated"
    else
      status = "price_updated"
    end
    
    #update_attributes(payment_status_name: status)
    
    return "<div class=\"#{status}\">#{status}</div>".html_safe
  end
  
  def display_title
    if ['confirmed'].include?(status.name)
      return "ĐƠN HÀNG"
    else
      return "BẢNG BÁO GIÁ"
    end
    
  end
  
  def display_description
    arr = []
    order_details.each do |od|
      p_str = "<div class=\"order-desc-line-item quantity-#{od.quantity}\">"
      p_str += "<label>[#{od.quantity.to_s}]</label> " 
      p_str += od.product.display_name.strip
      p_str += "</div>"
      arr << p_str
    end

    str = "<div class=\"order-desc-line-items\">"+arr.join(" ")+"</div>"
    return str.html_safe
  end
  
  def price=(new_price)
    self[:discount_amount] = new_price.to_s.gsub(/\,/, '')
  end
  
  def calculate_discount
    if discount > 0
      self[:discount_amount] = total*(discount.to_f/100)
    end    
  end
  
end
