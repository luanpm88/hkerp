class Order < ActiveRecord::Base
  attr_accessor :debt_days

  validates :supplier_id, presence: true
  validates :customer_id, presence: true
  validates :order_date, presence: true
  validates :order_deadline, presence: true
  
  belongs_to :customer, :class_name => "Contact"
  belongs_to :supplier, :class_name => "Contact"
  belongs_to :tax
  belongs_to :payment_method
  belongs_to :salesperson, :class_name => "User"
  belongs_to :purchase_manager, :class_name => "User"
  
  has_many :order_details, :dependent => :destroy
  
  accepts_nested_attributes_for :order_details
  
  #before_create :create_quotation_code
  
  #has_one :older, :class_name => "Order", :foreign_key => "id"
  #belongs_to :newer, :class_name => "Order", :foreign_key => "id"
  
  belongs_to :newer, class_name: "Order"
  has_one :older, class_name: "Order", foreign_key: "newer_id", :dependent => :destroy
  
  has_many :drafts, class_name: "Order", foreign_key: "parent_id", :dependent => :destroy
  belongs_to :parent, class_name: "Order"
  
  has_and_belongs_to_many :order_statuses
  
  belongs_to :order_status
  
  has_many :sales_deliveries, :dependent => :destroy
  
  has_many :deliveries, :dependent => :destroy
  
  has_many :payment_records, :dependent => :destroy
  
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
    
    return chuoi.strip.capitalize + " đồng"
  end
  
  def status
    if self.order_status.nil?      
      return self.set_status('new')      
    end
    
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
    return true
  end
  
  def confirm_items
    if order_details.count == 0
      return false
    end
    
    self.set_status('items_confirmed')
    return true
  end
  
  def self.customer_orders
    order("order_date DESC").where("supplier_id="+Contact.HK.id.to_s)
      .where(parent_id: nil)
  end
  
  def self.purchase_orders
    order("order_date DESC").where("supplier_id!="+Contact.HK.id.to_s)
      .where(parent_id: nil)
  end
  
  def is_purchase
    return self.customer == Contact.HK
  end
  
  def self.statistics(year, month=nil)
    status = OrderStatus.get("confirmed")
    
    total_buy = 0.00
    total_sell = 0.00
    total_buy_with_vat = 0.00
    total_sell_with_vat = 0.00
    total_vat_buy = 0.00
    total_vat_sell = 0.00
    
    sell_orders = Order.customer_orders                  
                  .where('extract(year from order_date) = ?', year)
    if month.present?
      sell_orders = sell_orders.where('extract(month from order_date) = ?', month) 
    end
                  
        
    sell_orders.each do |order|
      if order.newer.nil?
        total_sell += order.total
        total_sell_with_vat += order.total_vat
        total_vat_sell += order.vat_amount
      end      
    end
    
    buy_orders = Order.purchase_orders                  
                  .where('extract(year from order_date) = ?', year)
    if month.present?
      buy_orders = buy_orders.where('extract(month from order_date) = ?', month) 
    end
        
    buy_orders.each do |order|
      if order.newer.nil?
        total_buy += order.total
        total_buy_with_vat += order.total_vat
        total_vat_buy += order.vat_amount
      end      
    end
    
    return {
      total_buy: format_price(total_buy),
      total_sell: format_price(total_sell),
      total_buy_with_vat: format_price(total_buy_with_vat),
      total_sell_with_vat: format_price(total_sell_with_vat),
      total_vat_buy: format_price(total_vat_buy),
      total_vat_sell: format_price(total_vat_sell)
    }
  end
  
  def self.get_confirmed_sales_orders
    status = OrderStatus.get("confirmed")
    
    orders = Order.customer_orders
                  .joins(:order_status).where(order_statuses: {name: "confirmed"}) # orders confirmed
    
    return orders
  end
  
  def self.get_confirmed_purchase_orders
    status = OrderStatus.get("confirmed")
    
    orders = Order.purchase_orders
                  .joins(:order_status).where(order_statuses: {name: "confirmed"}) # orders confirmed
    
    return orders
  end
  
  def get_outdated_orders
    orders = Order.where(parent_id: self.id)
                  .joins(:order_status).where(order_statuses: {name: "outdated"}) # orders confirmed
  end
  
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
          order = "products.name"
      end
      order += " "+params["order"]["0"]["dir"]
    end
    
    where = {}    
    where[:customer_id] = params["customer_id"] if params["customer_id"].present?
    where[:supplier_id] = params["supplier_id"] if params["supplier_id"].present?
    where[:salesperson_id] = user.id
    
    if params[:purchase]
      @items = self.purchase_orders
    else
      @items = self.customer_orders
    end
    
    @items = @items.where('extract(year from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["year"]) if params["year"].present?
    @items = @items.where('extract(month from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["month"]) if params["month"].present?
    @items = @items.where('extract(day from order_date AT TIME ZONE ?) = ?', Time.zone.tzinfo.identifier, params["day"]) if params["day"].present?
    
    @items = @items.where(where)
    @items = @items.search(params["search"]["value"]) if !params["search"]["value"].empty?    
    @items = @items.order(order) if !order.nil?
    
    total = @items.count
    
    @items = @items.limit(params[:length]).offset(params["start"])
    data = []
    
    @items.each do |item|
      
      if params[:purchase]
        name_col = item.supplier.name
      else
        name_col = item.customer.name
      end
      
      puts User.current_user
      
      
      
      row = [
              item.quotation_code,              
              link_helper.link_to(name_col, {controller: "orders", action: "show", id: item.id}, class: "fancybox.iframe show_order"),              
              '<div class="text-right">'+item.formated_total_vat+'</div>',
              #'<div class="text-center">'+item.order_details.count.to_s+'</div>',
              '<div class="text-center">'+item.salesperson.name+'</div>',
              '<div class="text-center">'+item.purchase_manager_name+'</div>',
              '<div class="text-center">'+item.order_date_formatted+'</div>',
              '<div class="text-center">'+item.delivery_status.html_safe+'</div>',
              '<div class="text-center">'+item.display_status.html_safe+'</div>',
              ''
            ]
      data << row
    end 
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @items}
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
  
  def delivery_status
    
    if status.name != 'confirmed'
      str = ""
      
      if is_out_of_stock
        str += '<div class="red">out_of_stock</div> '
      end
      
      return str
    end 
    
    if is_delivered?
      return '<div class="green">delivered</div> '
    else
      str = ""
      if has_return_items
        str += '<div class="orange">returnback</div> '
      end
      if has_delvery_items
        str += '<div class="orange">not_delivered</div> '
      end
      if is_out_of_stock
        str += '<div class="red">out_of_stock</div> '
      end
      
      return str
    end
  end
  
  def paid_amount
    total = payment_records.sum :amount
    
    get_outdated_orders.each do |o|
      total += o.payment_records.sum :amount
    end
    
    return total
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
  
  def paid_status
    if paid_amount > total_vat
      return '<div class="orange">payback</div>'
    elsif paid_amount == total_vat
      return '<div class="green">paid</div>'
    elsif !debt_date.nil? && debt_date > order_date
      return '<div class="blue">debt</div>'
    else
      return '<div class="orange">waiting</div>'      
    end    
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
  
  def all_deliveries
    parent = self.parent.nil? ? self : self.parent
    
    orders = Order.select("id").where(parent_id: parent.id)
                  .joins(:order_status).where(order_statuses: {name: "outdated"}) # orders confirmed
    
    ids = [parent.id]
    
    orders.each do |order|
      ids << order.id
    end
    
    deliveries = Delivery.where(order_id: ids).order("created_at DESC")
  end
  
  def all_payment_records
    parent = self.parent.nil? ? self : self.parent
    
    orders = Order.select("id").where(parent_id: parent.id)
                  .joins(:order_status).where(order_statuses: {name: "outdated"}) # orders confirmed
    
    ids = [parent.id]
    
    orders.each do |order|
      ids << order.id
    end
    
    payment_records = PaymentRecord.where(order_id: ids).order("created_at DESC")
  end
  
  def display_status
    if self.status.nil?
    else
      if status.name == 'new'
        return "<div class=\"grey\">#{status.name}</div>".html_safe
      elsif status.name == 'confirmed'
        return "<div class=\"green\">#{status.name}</div>".html_safe
      elsif status.name == 'items_confirmed'
        return "<div class=\"orange\">#{status.name}</div>".html_safe
      elsif status.name == 'price_confirmed'
        return "<div class=\"orange\">#{status.name}</div>".html_safe
      else
        return status.name
      end
    end
  end
  
  def out_of_stock_details
    # out of stock details
    str = ""
    
    if is_out_of_stock    
      order_details.each do |od|
        str += '<div>'+od.product_name+'(<strong class="red">-'+od.out_of_stock_count.to_s+'</strong>) '+'</div>' if od.is_out_of_stock
      end
    end
      
    return str.html_safe
  end
  
  def self.pricing_orders(user)
    orders = Order.customer_orders
                  .where('purchase_manager_id=? OR purchase_manager_id IS NULL', user.id)
                  .joins(:order_status).where(order_statuses: {name: ["confirmed","items_confirmed","price_confirmed"]})
  end
  
  def confirm_price
    order_details.each do |od|
      if od.product.product_prices.count == 0 || od.product.product_price.price != od.price
        return false
      end
    end
    
    set_status("price_confirmed")
    
    return true
  end
  
  def purchase_manager_name
    purchase_manager.nil? ? "" : purchase_manager.name
  end
  
  def deposit=(value)
    self[:deposit] = value.to_s.gsub(/\,/, '')
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
  
end
