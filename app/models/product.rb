class Product < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include PgSearch
  
  validates :name, presence: true
  #validates :product_code, presence: true
  #validates :unit, presence: true
  validates :categories, presence: true
  validates :manufacturer, presence: true
  
  #validate :check_valid_serial_numbers
  
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
  
  has_many :orders, :through => :order_details
  
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
                  when "6"
                    order = "products.stock"
                  else
                    order = "products.updated_at DESC"
                  end
                  order += " "+params["order"]["0"]["dir"]
                else
                  order = "updated_at DESC"
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
      
      
      case params[:page]
      when "statistics"
                trashed_class =  product.status == 0 ? "trashed" : ""
                
                from_date = params[:from_date].to_date
                to_date = params[:to_date].to_date
                
                col_0 = product.categories.first.name
                col_1 = product.manufacturer.name
                col_2 = product.name+" "+product.product_code+"<br />"+product.product_log_link
                col_3 = product.statistic_stock(from_date).to_s
                
                ic = product.import_count(from_date, to_date)
                col_4 = ic.to_s+
                            "<br />("+product.import_amount_formated(from_date, to_date).to_s+')'
                col_4 = "+"+col_4 if ic > 0
                
                ec = product.export_count(from_date, to_date)
                col_5 = ec.to_s+
                            "<br />("+product.export_amount_formated(from_date, to_date).to_s+')'
                col_5 = "-"+col_5 if ec > 0
                            
                col_6 = product.combination_count_formated(from_date, to_date).to_s
                
                su = product.stock_update_count(from_date, to_date)
                col_7 = su.to_s
                col_7 = "+"+col_7 if su > 0
                
                col_8 = product.statistic_stock(to_date).to_s
                
                item = [
                        "<div class=\"text-left #{trashed_class}\">"+col_0+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+col_1+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+col_2+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+col_3+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+col_4+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+col_5+'</div>',
                        
                        "<div class=\"text-center #{trashed_class}\">"+col_6+'</div>',
                        "<div class=\"text-right #{trashed_class}\">"+col_7+'</div>',                        
                        "<div class=\"text-center #{trashed_class}\">"+col_8+'</div>',                 
                        ''

                      ]
                data << item
                actions_col = 0
      else
                trashed_class =  product.status == 0 ? "trashed" : ""
                item = ['<div class="checkbox check-default"><input id="checkbox#{product.id}" type="checkbox" value="1"><label for="checkbox#{product.id}"></label></div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.categories.first.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.manufacturer.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.name+" "+product.product_code+'</div>',
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
  
  def update_price(params, user)
    new_price = product_prices.new(price: params[:price],
      supplier_price: params[:supplier_price],
      supplier_id: params[:supplier_id],
      customer_id: params[:customer_id],
      user_id: user.id,
    )
    if new_price.price != self.product_price.price || new_price.supplier_price != self.product_price.supplier_price || new_price.supplier_id != self.product_price.supplier_id || new_price.customer_id != self.product_price.customer_id
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
    (!product_price.updated_at.nil? && (Time.now.to_date - product_price.updated_at.to_date).to_i >= 30) || product_price.nil? || product_price.price.nil?
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
    count += combinations.where(combined: [nil,true]).sum(:quantity)-combination_details.joins(:combination).where(combinations: {combined: [nil,true]}).sum(:quantity)
    count += -combinations.where(combined: false).sum(:quantity)+combination_details.joins(:combination).where(combinations: {combined: false}).sum(:quantity)
    
    #count for sales delivery
    count -= delivery_details
                      .joins(:delivery)
                      .joins(:order_detail => :order)
                      .where(deliveries: {status: 1})
                      .where(orders: {supplier_id: Contact.HK.id})
                      .sum(:quantity)
    
    #count for purchase delivery
    count += delivery_details
                      .joins(:delivery)
                      .joins(:order_detail => :order)
                      .where(deliveries: {status: 1})
                      .where(orders: {customer_id: Contact.HK.id})
                      .sum(:quantity)
    
    #count for stock update
    count += stock_update_count
    
    if self.stock.nil? || self.stock != count
      self.update_attributes(stock: count)
    end
    
    return count
    
  end
  
  def statistic_stock(datetime)
    count = 0
    #count for combinations
    #count += combinations.where("created_at <= ?", datetime).sum(:quantity)-combination_details.where("created_at <= ?", datetime).sum(:quantity)
    count += combinations.where("combinations.created_at <= ?", datetime).where(combined: [nil,true]).sum(:quantity)-combination_details.joins(:combination).where("combination_details.created_at <= ?", datetime).where(combinations: {combined: [nil,true]}).sum(:quantity)
    count += -combinations.where("combinations.created_at <= ?", datetime).where(combined: false).sum(:quantity)+combination_details.joins(:combination).where("combination_details.created_at <= ?", datetime).where(combinations: {combined: false}).sum(:quantity)
    
    #count for sales delivery
    count -= order_details
                      .joins(:order => :order_status)
                      .where(order_statuses: {name: ["finished"]})
                      .where(orders: {supplier_id: Contact.HK.id})
                      .where("orders.order_date < ?", datetime)
                      .sum(:quantity)
    
    #count for purchase delivery
    count += order_details
                      .joins(:order => :order_status)
                      .where(order_statuses: {name: ["finished"]})
                      .where(orders: {customer_id: Contact.HK.id})
                      .where("orders.order_date < ?", datetime)
                      .sum(:quantity)
    
    #count for stock update
    count += product_stock_updates
              .where("created_at < ?", datetime)
              .sum(:quantity)
    
    return count    
  end
  
  def stock_update_count(from_date=nil, to_date=nil)
    result = product_stock_updates
    if from_date.present? && to_date.present?
      result = result.where('created_at >= ?', from_date).where('created_at <= ?', to_date)
    end
    result = result.sum(:quantity)
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
  
  def self.statistics(from_date, to_date)
    Product.joins(:categories, :manufacturer).order("categories.name, manufacturers.name")
  end
  
  def import_count(from_date=nil, to_date=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {customer_id: Contact.HK.id})
    if from_date.present? && to_date.present?
      products = products.where('orders.order_date >= ?', from_date).where('orders.order_date <= ?', to_date)
    end
    
    
    count = products.sum("quantity")
  end
  
  
  
  def export_count(from_date=nil, to_date=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {supplier_id: Contact.HK.id})
    if from_date.present? && to_date.present?
      products = products.where('orders.order_date >= ?', from_date).where('orders.order_date <= ?', to_date)
    end
    
    count = products.sum("order_details.quantity")
  end
  
  def export_amount(from_date=nil, to_date=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {supplier_id: Contact.HK.id})

    if from_date.present? && to_date.present?
      products = products.where('orders.order_date >= ?', from_date).where('orders.order_date <= ?', to_date)
    end
    
    amount = products.sum("price*quantity")
  end
  
  def export_amount_formated(from_date=nil, to_date=nil)
    Order.format_price(export_amount(from_date, to_date))
  end
  
  def import_amount(from_date=nil, to_date=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
              .where(orders: {customer_id: Contact.HK.id})
    
    if from_date.present? && to_date.present?
      products = products.where('orders.order_date >= ?', from_date).where('orders.order_date <= ?', to_date)
    end
    
    
    
    amount = products.sum("price*quantity")
  end
  
  def import_amount_formated(from_date=nil, to_date=nil)
    Order.format_price(import_amount(from_date, to_date))
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
  
  def product_log(from_date, to_date)
    import_icon = '<i class="icon-download-alt"></i> '.html_safe
    export_icon = '<i class="icon-external-link"></i> '.html_safe
    #Order details, sales and purchases
    od_details = order_details
                      .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
                      .where(order_statuses: {name: ["finished","confirmed"]})
                      .where('orders.order_date >= ?', from_date)
                      .where('orders.order_date <= ?', to_date)
    
    #Delivery details, sales and purchases
    statuses = OrderStatus.where(name: ["finished","confirmed"])    
    d_details = delivery_details
              .joins(:delivery)
              .joins(:order_detail => :order) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(deliveries: {status: 1})
              .where(orders: {order_status_id: statuses.map(&:id)})
              .where('orders.order_date >= ?', from_date)
              .where('orders.order_date <= ?', to_date)
    
    history = []    
    od_details.each do |od|
      o = od.order
      if o.is_purchase
        line = {user: o.purchaser, date: o.created_at, note: "Buy from [#{o.supplier.name}]", link: o.order_link, quantity: od.quantity}
      else
        line = {user: o.salesperson, date: o.created_at, note: "Ordered from [#{o.customer.name}]", link: o.order_link, quantity: od.quantity}
      end
      history << line
    end
    
    d_details.each do |dd|
      o = dd.order_detail.order
      d = dd.delivery
      if o.is_purchase
        if dd.delivery.is_return == 1
          line = {user: d.creator,
                  date: d.created_at, note: "Return items to [#{o.supplier.name}]",
                  link: d.delivery_link,
                  quantity: export_icon+dd.quantity.to_s}
        else
          line = {user: d.creator,
                  date: d.created_at,
                  note: "Recieved items from [#{o.supplier.name}]",
                  link: d.delivery_link,
                  quantity: import_icon+dd.quantity.to_s}
        end
      else
        if dd.delivery.is_return == 1
          line = {user: d.creator, date: d.created_at, note: "Recieved returned items from [#{o.customer.name}]", link: d.delivery_link, quantity: import_icon+dd.quantity.to_s}
        else
          line = {user: d.creator, date: d.created_at, note: "Deliver items to [#{o.customer.name}]", link: d.delivery_link, quantity: export_icon+dd.quantity.to_s}
        end
      end
      history << line
    end
    
    #combination
    coms = combinations
              .where('created_at >= ?', from_date)
              .where('created_at <= ?', to_date)
    
    coms.each do |c|
      c_str = ""
      c.combination_details.each do |cd|
        c_str += "<br />"
        c_str += "----- #{cd.product.name} [<strong>#{cd.quantity}</strong>]"
      end
      
      if c.combined.nil? || c.combined
        line = {user: c.user, date: c.created_at, note: "Combining:"+c_str, link: "", quantity: import_icon+c.quantity.to_s}
      else
        line = {user: c.user, date: c.created_at, note: "De-Combining:"+c_str, link: "", quantity: export_icon+c.quantity.to_s}
      end
      
      history << line
    end
    
    #combination
    com_ds = combination_details
              .where('created_at >= ?', from_date)
              .where('created_at <= ?', to_date)
    
    com_ds.each do |cd|
      if cd.combination.combined.nil? || cd.combination.combined
        line = {user: cd.combination.user,date: cd.created_at, note: "Combined with others to create [#{cd.combination.product.name}]", link: "", quantity: export_icon+cd.quantity.to_s}
      else
        line = {user: cd.combination.user,date: cd.created_at, note: "Added by de-combine [#{cd.combination.product.name}]", link: "", quantity: import_icon+cd.quantity.to_s}
      end
      
      history << line
    end
    
    #stock update
    stocks = product_stock_updates
              .where('created_at >= ?', from_date)
              .where('created_at <= ?', to_date)
              
    stocks.each do |s|      
      if s.quantity > 0
        line = {user: s.user,date: s.created_at, note: "Custom Imported", link: "", quantity: import_icon+s.quantity.to_s}
      else
        line = {user: s.user,date: s.created_at, note: "Custom Exported", link: "", quantity: export_icon+s.quantity.to_s}
      end
      history << line
    end
    
    #price updated
    prices = product_prices
              .where('created_at >= ?', from_date)
              .where('created_at <= ?', to_date)
              
    prices.each do |s|      
      line = {user: s.user,date: s.created_at, note: "Price changed: <br />[Supplier: #{s.supplier_name}; Sup.Price: #{s.supplier_price_formated}; Sel.Price: #{s.price_formated}]", link: "", quantity: ""}
      history << line
    end
    
    #added
    line = {user: self.user, date: self.created_at, note: "Created!", link: "", quantity: ""}
    history << line if from_date.to_datetime <= self.created_at && self.created_at <= to_date
    
    
    return history.sort {|a,b| b[:date] <=> a[:date]}
  end
  
  def product_log_link
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to '<i class="icon-time"></i> Product Logs'.html_safe, {controller: "products", action: "product_log", id: self.id},target: "blank", :class => "btn btn-primary btn-mini"
    
    
  end
  
  def combination_count(from_date=nil, to_date=nil)
    in_c = combinations.where(combined: [nil,true])
    if from_date.present? && to_date.present?
      in_c = in_c.where('created_at >= ?', from_date).where('created_at <= ?', to_date)
    end
    in_c = in_c.sum(:quantity)
    
    in_c_de = combinations.where(combined: [false])
    if from_date.present? && to_date.present?
      in_c_de = in_c_de.where('created_at >= ?', from_date).where('created_at <= ?', to_date)
    end
    in_c_de = in_c_de.sum(:quantity)
    
    
    out_c = combination_details.joins(:combination).where(combinations: {combined: [nil,true]})
    if from_date.present? && to_date.present?
      out_c = out_c.where('combination_details.created_at >= ?', from_date).where('combination_details.created_at <= ?', to_date)
    end
    out_c = out_c.sum(:quantity)
    
    out_c_de = combination_details.joins(:combination).where(combinations: {combined: [false]})
    if from_date.present? && to_date.present?
      out_c_de = out_c_de.where('combination_details.created_at >= ?', from_date).where('combination_details.created_at <= ?', to_date)
    end
    out_c_de = out_c_de.sum(:quantity)
    
    count = in_c - out_c + out_c_de - in_c_de
    
    return count
  end
  
  def combination_count_formated(from_date=nil, to_date=nil)
    count = combination_count(from_date, to_date)
    if count > 0
        "+"+count.to_s
    else
        count.to_s
    end
    
  end
  
end
