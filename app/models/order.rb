class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  
  validates :supplier_id, presence: true
  validates :customer_id, presence: true
  validates :order_date, presence: true
  validates :order_deadline, presence: true
  
  belongs_to :customer, :class_name => "Contact"
  belongs_to :supplier, :class_name => "Contact"
  belongs_to :tax
  belongs_to :payment_method
  belongs_to :salesperson, :class_name => "User"
  
  has_many :order_details, :dependent => :destroy
  
  accepts_nested_attributes_for :order_details
  
  #before_create :create_quotation_code
  
  #has_one :older, :class_name => "Order", :foreign_key => "id"
  #belongs_to :newer, :class_name => "Order", :foreign_key => "id"
  
  has_one :newer, class_name: "Order", foreign_key: "older_id"
  belongs_to :older, class_name: "Order", :dependent => :destroy
  
  has_and_belongs_to_many :order_statuses
  
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
    total = 0
    order_details.each {|item|
      total = total + item.total
    }
    return total*(tax.rate/100+1) - total
  end
  
  def vat_amount
    return total*(tax.rate/100)
  end
  
  def formated_total
    number_to_currency(total, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_total_vat
    number_to_currency(total_vat, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_vat_amount
    number_to_currency(vat_amount, precision: 0, unit: '', delimiter: ".")
  end
  
  def formated_warranty_cost
    number_to_currency(total, precision: 0, unit: '', delimiter: ".")
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
  
  def order_history_lines
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
    if self.order_statuses.first.nil?      
      return self.set_status('quotation')      
    end
    
    return self.order_statuses.order("created_at DESC").first
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
    self.set_status('confirmed')
  end
  
  def self.customer_orders
    order("order_date DESC").where("supplier_id="+Contact.HK.id.to_s)
  end
  
  def self.purchase_orders
    order("order_date DESC").where("supplier_id!="+Contact.HK.id.to_s)
  end
  
  def is_purchase
    self.customer == Contact.HK
  end
  
  def self.statistics_by_month(year, month)
    status = OrderStatus.get("confirmed")
    
    orders = Order.customer_orders
                  .where("EXISTS(SELECT 1 from order_statuses_orders where order_status_id=#{status.id})")
                  .where('extract(year from order_date) = ?', year)
                  .where('extract(month from order_date) = ?', month)
    
    return orders
  end
  
  def self.get_sales_orders_with_delivery
    status = OrderStatus.get("confirmed")
    
    orders = Order.customer_orders
                  .where("EXISTS(SELECT 1 from order_statuses_orders where order_status_id=#{status.id})")
    
    return orders
  end
  
  def self.datatable(params)
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
    #where[] = "extract(year from order_date) = 2015"
    
    if params[:purchase]
      @items = self.purchase_orders
    else
      @items = self.customer_orders
    end
    
    @items = @items.where('extract(year from order_date) = ?', params["year"]) if params["year"].present?
    @items = @items.where('extract(month from order_date) = ?', params["month"]) if params["month"].present?
    @items = @items.where('extract(day from order_date) = ?', params["day"]) if params["day"].present?
    
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
      
      row = ['<div class="checkbox check-default"><input id="checkbox#{item.id}" type="checkbox" value="1"><label for="checkbox#{item.id}"></label></div>',
              link_helper.link_to(name_col, {controller: "orders", action: "show", id: item.id}, class: "fancybox.iframe show_order"),              
              '<div class="text-right">'+item.formated_total_vat+'</div>',
              '<div class="text-center">'+item.order_details.count.to_s+'</div>',
              '<div class="text-center">'+item.salesperson.name+'</div>',
              '<div class="text-center">'+item.order_date_formatted+'</div>',
              '<div class="text-center">'+item.status_formatted+'</div>',
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
  
end
