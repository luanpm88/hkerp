class Product < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include PgSearch
  
  validates :name, presence: true
  #validates :product_code, presence: true
  #validates :unit, presence: true
  validates :categories, presence: true
  validates :manufacturer, presence: true
  
  validate :check_valid_serial_numbers
  
  has_and_belongs_to_many :categories
  belongs_to :manufacturer
  belongs_to :user
  
  has_many :order_details
  has_many :delivery_details
  has_many :combination_details
  has_many :combinations
  has_many :product_stock_updates
  
  has_many :product_prices, :dependent => :destroy
  
  
  has_many :product_parts, :dependent => :destroy
  has_many :parts, :through => :product_parts, :source => :part
  
  accepts_nested_attributes_for :product_parts, :reject_if => lambda { |c| c[:part_id].blank? || c[:id].present? }, allow_destroy: true

  has_many :parent_parts, :class_name => "ProductPart", :foreign_key => "part_id"
  has_many :parent, :through => :parent_parts, :source => :part
  
  before_save :fix_serial_numbers
  
  
  def order_supplier_history
    @list = OrderDetail.joins(:order).where("order_id IS NOT NULL")
                        .where(orders: {customer_id: Contact.HK.id})
                        .where(product_id: id)
                        .order("created_at DESC").limit(10)
    @html = "<ul>"
    @list.each do |item|
      @html += "<li>"+item.order.supplier.name+": <br />Price: <strong>"+item.formated_price+" VND</strong></li>";
    end
    @html += "</ul>";
    
    return @html
  end
  
  def formated_price
    Order.format_price(price)
  end
  
  def price=(new_price)
    self[:price] = new_price.to_s.gsub(/[\,]/, '')
  end
  
  def display_name
    result = ''
    if categories.first.name != 'none'
      result += categories.first.name + " "
    end
    
    if manufacturer.name != 'none'
      result += manufacturer.name + " "
    end
    
    
    result += name
    result += " " + product_code if !product_code.nil?
    
    return result.strip
  end
  
  #def self.search(q)
  #  self.joins(:categories,:manufacturer).where("CONCAT(lower(categories.name),' ',lower(manufacturers.name),' ',lower(products.name),' ',lower(products.product_code)) LIKE '%#{q.downcase}%'").map {|model| {:id => model.id, :text => model.display_name} }
  #end
  
  pg_search_scope :search,
                against: [:name, :product_code],
                associated_against: {
                  categories: :name,
                  manufacturer: :name
                },
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(q)
    self.where(status: 1).search(q).limit(50).map {|model| {:id => model.id, :text => model.display_name} }
  end
  
  def self.datatable(params)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    
    case params[:page]
      when "statistics"
                if !params["order"].nil?
                  case params["order"]["0"]["column"]
                  when "0"
                    order = "categories.name"
                  when "1"
                    order = "manufacturers.name"
                  when "2"
                    order = "products.name"
                  else
                    order = "products.updated_at DESC"
                  end
                  order += " "+params["order"]["0"]["dir"]
                end
      else
                if !params["order"].nil?
                  case params["order"]["0"]["column"]
                  when "0"
                    order = "products.id"
                  when "1"
                    order = "categories.name"
                  when "2"
                    order = "manufacturers.name"
                  when "3"
                    order = "products.name"
                  else
                    order = "products.updated_at DESC"
                  end
                  order += " "+params["order"]["0"]["dir"]
                end
      end
    
    
    where = "true"    
    where += " AND products.manufacturer_id IN (#{params["manufacturers"]})" if params["manufacturers"].present?
    where += " AND categories.id = #{params["category"]}" if params["category"].present?

    @products = self.joins(:categories).joins(:manufacturer).where(where)
    @products = @products.search(params["search"]["value"]) if params["search"]["value"].present?    
    @products = @products.order(order) if !order.nil?

    @products = @products.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 7
    @products.each do |product|
      
      edit_link = '<a href="'+Rails.application.routes.url_helpers.edit_product_path(product)+'" class="btn btn-info btn-xs btn-mini">Edit</a> '
      update_price_link = link_helper.link_to('Price', {controller: "products", action: "update_price", id: product.id}, class: "btn btn-info btn-xs btn-mini")
      update_stock_link = link_helper.link_to('Update Stock', {controller: "product_stock_updates", action: "new", product_id: product.id}, class: "btn btn-info btn-xs btn-mini")
      trash_link = link_helper.link_to('Trash', {controller: "products", action: "trash", product_id: product.id}, method: :patch, class: "btn btn-info btn-xs btn-mini")
      
      
      
      
      case params[:page]
      when "statistics"
                trashed_class =  product.status == 0 ? "trashed" : ""
                item = [
                        "<div class=\"text-left #{trashed_class}\">"+product.categories.first.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.manufacturer.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.name+"<br />"+product.product_activity_history_link+'</div>',
                        "<div class=\"text-right #{trashed_class}\">"+product.import_count(params[:year], params[:month]).to_s+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.import_amount_formated(params[:year], params[:month]).to_s+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.export_count(params[:year], params[:month]).to_s+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.export_amount_formated(params[:year], params[:month]).to_s+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.calculated_stock.to_s+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.combination_count.to_s+'</div>',                        
                        ''

                      ]
                data << item
                actions_col = 0
      else
                trashed_class =  product.status == 0 ? "trashed" : ""
                item = ['<div class="checkbox check-default"><input id="checkbox#{product.id}" type="checkbox" value="1"><label for="checkbox#{product.id}"></label></div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.categories.first.name+"<br />"+product.product_activity_history_link+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.manufacturer.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.name+'</div>',
                        "<div class=\"text-right #{trashed_class}\">"+product.product_price.supplier_price_formated+'</div>',
                        "<div class=\"text-right #{trashed_class}\">"+product.product_price.price_formated+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.calculated_stock.to_s+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.display_status+'</div>',
                        ''
                      ]
                data << item
                actions_col = 8
      end
                
    end    
    
    total = self.joins(:categories).joins(:manufacturer).where(where)
    total = total.search(params["search"]["value"]) if !params["search"]["value"].empty?    
    total = total.order(order) if !order.nil?
    total = total.count("products.id");
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @products, actions_col: actions_col}
  end
  
  def self.extract_serial_numbers(string)
    arr = []
    
    if !string.nil?
      string.split("\r\n").each do |line|
        item = line.strip
        if item.length < 40 && item.length > 4
          arr << item
        end      
      end
    end
      
    return arr
  end
  
  def serial_numbers_extracted
    Product.extract_serial_numbers(serial_numbers)
  end
  
  def valid_serial_numbers
    return serial_numbers_extracted.count <= calculated_stock
  end
  
  def fix_serial_numbers
    self.serial_numbers = serial_numbers_extracted.join("\r\n")
  end
  
  def serial_numbers_html
    serial_numbers.gsub("\r\n","<br />")
  end
  
  def check_valid_serial_numbers
    if !valid_serial_numbers
      errors.add(:serial_numbers, "can't be greater than stock")
    end
  end
  
  def remove_serial_numbers(arr)
    new_arr = serial_numbers_extracted
    
    arr.each do |number|
      if new_arr.include?(number)
        new_arr.delete(number)
      end
    end
    
    self.serial_numbers = new_arr.join("\r\n")
    self.save
  end
  
  def insert_serial_numbers(arr)
    new_arr = serial_numbers_extracted
    
    arr.each do |number|
      if !new_arr.include?(number)
        new_arr << number
      end
    end
    
    self.serial_numbers = new_arr.join("\r\n")
    self.save
  end
  
  def product_price
    price = product_prices.order("created_at DESC").first
    
    if price.nil?
      return ProductPrice.new
    else
      return price
    end    
  end
  
  def update_price(params)
    new_price = product_prices.new(price: params[:price],
      supplier_price: params[:supplier_price],
      supplier_id: params[:supplier_id],
    )
    if new_price.price != self.product_price.price || new_price.supplier_price != self.product_price.supplier_price || new_price.supplier_id != self.product_price.supplier_id
      new_price.save
      return true
    end
    return true
  end
  
  def category
    categories.order("created_at DESC").first
  end
  
  def is_out_of_stock
    calculated_stock == 0
  end
  
  def is_price_outdated
    # if empty stock for 30 days
    (!is_out_of_stock && (Time.now.to_date - updated_at.to_date).to_i >= 30) || product_price.nil? || product_price.price.nil?
  end
  
  def price_status
    status = ""
    if is_price_outdated
      status = "price_outdated"
    else
      status = "price_updated"
    end
    
    #update_attributes(payment_status_name: status)
    
    return "<div class=\"#{status}\">#{status}</div>".html_safe
  end
  
  def is_combinable
    max_combinable > 0
  end
  
  def max_combinable
    if parts.count == 0
        return 0
    end
    
    count = 10000000000
    parts.each do |p|
      i = p.calculated_stock/(self.product_parts.where(part_id: p.id).first.quantity).to_i
      if count > i
        count = i
      end      
    end
    return count
  end
  
  
  
  def calculated_stock
    count = 0
    #count for combinations
    count += combinations.sum(:quantity)-combination_details.sum(:quantity)
    
    #count for sales delivery
    count -= delivery_details.joins(:order_detail => :order)
                            .where(orders: {supplier_id: Contact.HK.id})
                            .sum(:quantity)
    #count for purchase delivery
    count += delivery_details.joins(:order_detail => :order)
                            .where(orders: {customer_id: Contact.HK.id})
                            .sum(:quantity)
    
    #count for stock update
    count += product_stock_updates.sum(:quantity)
  end
  
  def wait_for_supply_count
    count = OrderDetail.joins(:order)
                .where(orders: {customer_id: Contact.HK.id})
                .where(orders: {parent_id: nil})
                .where("orders.delivery_status_name LIKE ?", "%not_delivered%")                
                .where(product_id: self.id).sum(:quantity)
    
    count -= DeliveryDetail.joins(:delivery => :order)
                .where(orders: {customer_id: Contact.HK.id})
                .where(orders: {parent_id: nil})
                .where("orders.delivery_status_name LIKE ?", "%not_delivered%")                
                .where(product_id: self.id).sum(:quantity)
    
    return count
  end
  
  def trash
    update_attributes(status: 0)
  end
  
  def un_trash
    update_attributes(status: 1)
  end
  
  def display_status
    status = ""
    if self.status == 1
      status = "active"
    else
      status = "trashed"
    end
    
    return "<div class=\"#{status}\">#{status}</div>".html_safe
  end
  
  def self.statistics(year, month=nil)
    Product.all
  end
  
  def import_count(year, month=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {customer_id: Contact.HK.id})
              .where('extract(year from orders.order_date) = ?', year)
    if month.present?
      products = products.where('extract(month from orders.order_date) = ?', month) 
    end
    
    count = products.sum("quantity")
  end
  
  def import_count_test(year, month=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {customer_id: Contact.HK.id})
              .where('extract(year from orders.order_date) = ?', year)
    if month.present?
      products = products.where('extract(month from orders.order_date) = ?', month) 
    end
    
    count = products
  end
  
  def export_count(year, month=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {supplier_id: Contact.HK.id})
    if month.present?
      products = products.where('extract(month from orders.order_date) = ?', month) 
    end
    
    count = products.sum("order_details.quantity")
  end
  
  def export_amount(year, month=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {supplier_id: Contact.HK.id})
              .where('extract(year from orders.order_date) = ?', year)
    if month.present?
      products = products.where('extract(month from orders.order_date) = ?', month) 
    end
    
    amount = products.sum("price*quantity")
  end
  
  def export_amount_formated(year, month=nil)
    Order.format_price(export_amount(year, month))
  end
  
  def import_amount(year, month=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {customer_id: Contact.HK.id})
              .where('extract(year from orders.order_date) = ?', year)
    if month.present?
      products = products.where('extract(month from orders.order_date) = ?', month) 
    end
    
    amount = products.sum("price*quantity")
  end
  
  def import_amount_formated(year, month=nil)
    Order.format_price(import_amount(year, month))
  end
  
  def price_history_link(button=true)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    if button
        link_helper.link_to '<i class="icon-time"></i> Price History'.html_safe, {controller: "products", action: "ajax_product_prices", id: self.id}, :class => "price-history btn btn-primary btn-mini fancybox.ajax"
    else
        link_helper.link_to '<i class="icon-time"></i> Price History'.html_safe, {controller: "products", action: "ajax_product_prices", id: self.id}, :class => "price-history fancybox.ajax"
    end
    
    
  end
  
  def product_activity_history(year, month=nil)
    #Order details, sales and purchases
    od_details = order_details
                      .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
                      .where(order_statuses: {name: ["finished"]})
                      .where('extract(year from orders.order_date) = ?', year)
    if month.present?
      od_details = od_details.where('extract(month from orders.order_date) = ?', month) 
    end
    
    #Delivery details, sales and purchases
    status = OrderStatus.where(name: 'finished').first    
    d_details = delivery_details
              .joins(:order_detail => :order) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(orders: {order_status_id: status.id})
              .where('extract(year from orders.order_date) = ?', year)
    if month.present?
      d_details = d_details.where('extract(month from orders.order_date) = ?', month) 
    end
    
    history = []    
    od_details.each do |od|
      o = od.order
      if o.is_purchase
        line = {date: o.order_date.strftime("%Y-%m-%d"), note: "Buy from [#{o.supplier.name}]", link: o.order_link, quantity: od.quantity}
      else
        line = {date: o.order_date.strftime("%Y-%m-%d"), note: "Sell to [#{o.customer.name}]", link: o.order_link, quantity: od.quantity}
      end
      history << line
    end
    
    d_details.each do |dd|
      o = dd.order_detail.order
      d = dd.delivery
      if o.is_purchase
        if dd.delivery.is_return == 1
          line = {date: dd.created_at.strftime("%Y-%m-%d"), note: "Return items to [#{o.supplier.name}]", link: d.delivery_link, quantity: -dd.quantity}
        else
          line = {date: dd.created_at.strftime("%Y-%m-%d"), note: "Recieved items from [#{o.supplier.name}]", link: d.delivery_link, quantity: dd.quantity}
        end
      else
        if dd.delivery.is_return == 1
          line = {date: dd.created_at.strftime("%Y-%m-%d"), note: "Recieved returned items to [#{o.customer.name}]", link: d.delivery_link, quantity: dd.quantity}
        else
          line = {date: dd.created_at.strftime("%Y-%m-%d"), note: "Deliver items to [#{o.customer.name}]", link: d.delivery_link, quantity: -dd.quantity}
        end
      end
      history << line
    end
    
    return history.sort {|a,b| a[:date] <=> b[:date]}
  end
  
  def product_activity_history_link
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to '<i class="icon-time"></i> Product Activities'.html_safe, {controller: "products", action: "product_activity_history", id: self.id},target: "blank", :class => "btn btn-primary btn-mini"
    
    
  end
  
  def combination_count
    count = combinations.sum(:quantity).count
    count -= combination_details.sum(:quantity).count
    
    return count
  end
  
end
