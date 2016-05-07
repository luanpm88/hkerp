class Product < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include PgSearch
  
  after_save :update_cache_search
  
  validates :name, presence: true
  #validates :product_code, presence: true
  #validates :unit, presence: true
  validates :categories, presence: true
  validates :manufacturer, presence: true
  
  
  
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
  
  accepts_nested_attributes_for :product_parts, :reject_if => lambda { |c| !c[:part_id].present? }, allow_destroy: true

  has_many :parent_parts, :class_name => "ProductPart", :foreign_key => "part_id"
  has_many :parent, :through => :parent_parts, :source => :part
  
  has_many :orders, :through => :order_details
  
  has_many :product_images
  accepts_nested_attributes_for :product_images, :reject_if => lambda { |c| !c[:filename].present? && !c[:created_at].present? }, allow_destroy: true
  
  before_save :fix_serial_numbers
  
  def self.all_products
    self.where(status: 1)
  end
  
  def order_supplier_history(user)
    @list = OrderDetail.joins(:order).where("order_id IS NOT NULL")
                      .where(orders: {parent_id: nil, salesperson_id: user.id, parent_id: nil, supplier_id: Contact.HK.id, order_status_name: ["confirmed","finished"]})
                      .where(product_id: id)
                      .order("created_at DESC").limit(10)
    @html = "<ul>"
    @list.each do |item|
      @html += "<li>"+item.order.customer.name+": <br />Price: <strong>"+item.formated_price+" VND</strong> (#{item.created_at.strftime("%Y-%m-%d")})</li>";
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
                  manufacturer: :name,
                  user: [:first_name, :last_name]
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
  
  def self.filter(params, user)
    where = "true"    
    where += " AND products.manufacturer_id IN (#{params["manufacturers"].join(",")})" if params["manufacturers"].present? && !params["search"]["value"].present?
    where += " AND categories.id IN (#{params["categories"].join(",")})" if params["categories"].present? && !params["search"]["value"].present?

    @products = self.joins(:categories).joins(:manufacturer).where(where)
    # @products = @products.search(params["search"]["value"]) if params["search"]["value"].present?
    @products = @products.where("LOWER(products.cache_search) LIKE ?", "%#{params["search"]["value"].strip.downcase}%") if params["search"]["value"].present?    
    
    
    return @products
  end
  
  def self.datatable(params, user)
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
                    order = "categories.name"
                  when "1"
                    order = "manufacturers.name"
                  when "2"
                    order = "products.name"
                  when "4"
                    order = "products.stock"
                  else
                    order = "products.updated_at DESC"
                  end
                  order += " "+params["order"]["0"]["dir"]
                else
                  order = "updated_at DESC"
                end
      end
    
    
    @products = self.filter(params, user)
    
    @products = @products.order(order) if !order.nil?
    total = @products.count("products.id");

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
                col_2 = product.name+" "+product.product_code+"<br />"+product.product_log_link+"<div>"+product.description[0..80]+"</div>"
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
                supplier_price = user.can?(:view_supplier_price, product) ? product.product_price.supplier_price_formated : "####"
                
                trashed_class =  product.status == 0 ? "trashed" : ""
                item = [
                        "<div class=\"text-left #{trashed_class}\">"+product.categories.first.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.manufacturer.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\"><strong class=\"main-title\">"+product.name+" "+product.product_code+"</strong><div>"+product.description[0..80]+"<div>#{(product.note.present? ? "(#{product.note})": "")}</div></div>"+'</div>',
                        #"<div class=\"text-right #{trashed_class}\">"+supplier_price+'</div>',
                        "<div class=\"text-right #{trashed_class}\">"+product.product_price.price_formated+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.calculated_stock.to_s+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.display_status+product.price_status+'</div>',
                        "<div class=\"text-center\"><a class=\"fancybox_image\" href=\"#{product.image}.png\"><img src=\"#{product.image(:thumb)}\" width=\"60\" /></a></div>",
                        product.user.nil? ? "" : "<div class=\"text-center\">"+product.user.staff_col+'</div>',
                        ''
                      ]
                data << item
                actions_col = 8
      end
                
    end    
    
    
    
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
  
  def product_image
    product_images.order("display_order").first
  end
  
  def image(type=nil)
    return "/img/photo.png" if product_image.nil?
    
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    
    return link_helper.url_for(controller: "product_images", action: "image", id: product_image.id, :type => type)   
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
    #if !params[:supplier_price].present?
    #  return false
    #end
    
    new_price = product_prices.new(
      price: params[:price],
      supplier_price: params[:supplier_price],
      supplier_id: params[:supplier_id],
      customer_id: params[:customer_id],
      user_id: user.id,
    )
    
    if !user.can? :update_public_price, self
      new_price.price = nil
    end
    
    if !user.can? :update_price, self
      new_price.supplier_price = nil
      new_price.supplier_id = nil
    end
    
    # calculate public price   
    new_price.calculate_price
    
    if new_price.price != self.product_price.price || new_price.supplier_price != self.product_price.supplier_price || new_price.supplier_id != self.product_price.supplier_id || new_price.customer_id != self.product_price.customer_id
      new_price.save
    else
      self.product_price.update_attribute("updated_at",Time.now)
    end
    
    p = Product.find(self.id)
    return p.product_price
  end
  
  def category
    categories.order("created_at DESC").first
  end
  
  def is_out_of_stock
    calculated_stock == 0
  end
  
  def is_price_outdated
    if product_price.nil?
       return true
    end
    
    if product_price.price.nil? || product_price.price.to_f == 0.00
       return true
    end
    
    if product_price.supplier_price.nil? || product_price.supplier_price.to_f == 0.00
       return true
    end
    
    if product_price.supplier_id.nil?
       return true
    end
    
    # if empty stock for 30 days
    if (!product_price.updated_at.nil? && (Time.now.to_date - product_price.updated_at.to_date).to_i >= 100)
      return true
    end
    
    return false
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
                      .where(orders: {order_status_name: ["confirmed","finished"]})
                      .where(deliveries: {status: 1})
                      .where(orders: {parent_id: nil, supplier_id: Contact.HK.id})
                      .sum(:quantity)
    
    #count for purchase delivery
    count += delivery_details
                      .joins(:delivery)
                      .joins(:order_detail => :order)
                      .where(orders: {order_status_name: ["confirmed","finished"]})
                      .where(deliveries: {status: 1})
                      .where(orders: {parent_id: nil, customer_id: Contact.HK.id})
                      .sum(:quantity)
    
    #count for stock update
    count += stock_update_count
    
    if self.stock.nil? || self.stock != count
      self.update_attributes(stock: count)
    end
    
    return count
    
  end
  
  def statistic_stock(datetime)
    datetime = datetime.end_of_day
    count = 0
    #count for combinations
    #count += combinations.where("created_at <= ?", datetime).sum(:quantity)-combination_details.where("created_at <= ?", datetime).sum(:quantity)
    count += combinations.where("combinations.created_at <= ?", datetime).where(combined: [nil,true]).sum(:quantity)-combination_details.joins(:combination).where("combination_details.created_at <= ?", datetime).where(combinations: {combined: [nil,true]}).sum(:quantity)
    count += -combinations.where("combinations.created_at <= ?", datetime).where(combined: false).sum(:quantity)+combination_details.joins(:combination).where("combination_details.created_at <= ?", datetime).where(combinations: {combined: false}).sum(:quantity)
    
    #count for sales delivery
    count -= order_details
                      .joins(:delivery)
                      .joins(:order => :order_status)
                      .where(order_statuses: {name: ["confirmed","finished"]})
                      .where(orders: {parent_id: nil, supplier_id: Contact.HK.id})
                      .where("orders.order_date < ?", datetime)
                      .sum(:quantity)
    
    #count for purchase delivery
    count += order_details
                      .joins(:delivery)
                      .joins(:order => :order_status)
                      .where(order_statuses: {name: ["confirmed","finished"]})
                      .where(orders: {parent_id: nil, customer_id: Contact.HK.id})
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
      result = result.where('created_at >= ?', from_date.beginning_of_day).where('created_at <= ?', to_date.end_of_day)
    end
    result = result.sum(:quantity)
  end
  
  def wait_for_supply_count
    count = OrderDetail.joins(:order)
                .where(orders: {customer_id: Contact.HK.id})
                .where(orders: {parent_id: nil})
                .where("orders.delivery_status_name LIKE ?", "%not_delivered%")                
                .where(product_id: self.id).sum(:quantity)
    
    count -= DeliveryDetail.joins(:delivery => :order).joins(:order_detail)
                .where(orders: {customer_id: Contact.HK.id})
                .where(orders: {parent_id: nil})
                .where("orders.delivery_status_name LIKE ?", "%not_delivered%")                
                .where(order_details: {product_id: self.id}).sum(:quantity)
    
    return count
  end
  
  def trash
    self.update_attribute(:status, 0)
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
              .where(order_statuses: {name: ["confirmed","finished"]})
              .where(orders: {parent_id: nil, customer_id: Contact.HK.id})
    if from_date.present? && to_date.present?
      products = products.where('orders.order_date >= ?', from_date.beginning_of_day).where('orders.order_date <= ?', to_date.end_of_day)
    end
    
    
    count = products.sum("quantity")
  end
  
  
  
  def export_count(from_date=nil, to_date=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["confirmed","finished"]})
              .where(orders: {parent_id: nil, supplier_id: Contact.HK.id})
    if from_date.present? && to_date.present?
      products = products.where('orders.order_date >= ?', from_date.beginning_of_day).where('orders.order_date <= ?', to_date.end_of_day)
    end
    
    count = products.sum("order_details.quantity")
  end
  
  def export_amount(from_date=nil, to_date=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["confirmed","finished"]})
              .where(orders: {parent_id: nil, supplier_id: Contact.HK.id})

    if from_date.present? && to_date.present?
      products = products.where('orders.order_date >= ?', from_date.beginning_of_day).where('orders.order_date <= ?', to_date.end_of_day)
    end
    
    amount = products.sum("price*quantity")
  end
  
  def export_amount_formated(from_date=nil, to_date=nil)
    Order.format_price(export_amount(from_date, to_date))
  end
  
  def import_amount(from_date=nil, to_date=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["confirmed","finished"]})
              .where(orders: {parent_id: nil, customer_id: Contact.HK.id})
    
    if from_date.present? && to_date.present?
      products = products.where('orders.order_date >= ?', from_date.beginning_of_day).where('orders.order_date <= ?', to_date.end_of_day)
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
  
  def product_log(from_date, to_date, user)
    import_icon = '<i class="icon-download-alt"></i> '.html_safe
    export_icon = '<i class="icon-external-link"></i> '.html_safe
    #Order details, sales and purchases
    od_details = order_details
                      .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
                      .where(order_statuses: {name: ["canceled","finished","confirmed"]})
                      .where(orders: {parent_id: nil})
                      .where('orders.order_date >= ?', from_date)
                      .where('orders.order_date <= ?', to_date)
    
    #Delivery details, sales and purchases
    statuses = OrderStatus.where(name: ["canceled","finished","confirmed"])    
    d_details = delivery_details
              .joins(:delivery)
              .joins(:order_detail => :order) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(deliveries: {status: 1})
              .where(orders: {order_status_id: statuses.map(&:id), parent_id: nil})
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
        line = {user: s.user,date: s.created_at, note: "Custom Imported: [#{s.note}]", link: "", quantity: import_icon+s.quantity.to_s}
      else
        line = {user: s.user,date: s.created_at, note: "Custom Exported: [#{s.note}]", link: "", quantity: export_icon+s.quantity.to_s}
      end
      history << line
    end
    
    #price updated
    prices = product_prices
              .where('created_at >= ?', from_date)
              .where('created_at <= ?', to_date)
              
    prices.each do |s|
      supplier_price = user.can?(:view_supplier_price, s.product) ? s.supplier_price_formated : "####"
      line = {user: s.user,date: s.created_at, note: "Price changed: <br />[Supplier: #{s.supplier_name}; Sup.Price: #{supplier_price}; Sel.Price: #{s.price_formated}]", link: "", quantity: ""}
      history << line
    end
    
    #added
    line = {user: self.user, date: self.created_at, note: "Created!", link: "", quantity: ""}
    history << line if from_date.to_datetime <= self.created_at && self.created_at <= to_date.to_datetime
    
    
    
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
      in_c = in_c.where('created_at >= ?', from_date.beginning_of_day).where('created_at <= ?', to_date.end_of_day)
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
  
  def self.find_by_serial_number(serial_number)
    products = Product.joins(:delivery_details => :delivery)
                      .where(deliveries: {status: 1})
                      .where("LOWER(delivery_details.serial_numbers) LIKE ? ", "%#{serial_number.downcase.strip}%")
                      .distinct
  end
  
  def find_deliveries_by_serial_number(serial_number)
    deliveries = Delivery.joins(:delivery_details)
                      .where(status: 1)
                      .where(delivery_details: {product_id: self.id})
                      .where("LOWER(delivery_details.serial_numbers) LIKE ? ", "%#{serial_number.downcase.strip}%")
                      .distinct
  end
  
  def find_serial_numbers_by_serial_number(serial_number)
    dds = delivery_details.joins(:delivery)
                      .where(deliveries: {status: 1})
                      .where("LOWER(delivery_details.serial_numbers) LIKE ? ", "%#{serial_number.downcase.strip}%")
                      .distinct
    
    ss = []
    dds.each do |dd|
      sa = Product.extract_serial_numbers(dd.serial_numbers)
      sa.each do |s|
        if s.downcase.include? serial_number.downcase.strip
          ss << s
        end        
      end
    end
    
    return ss
  end
  
  def self.stock_statistic
    public_total = 0.00
    public_count = 0
    public_count_no_price = 0
    supplier_total = 0.00
    supplier_count = 0
    supplier_count_no_price = 0
    self.all_products.each do |p|
      stock_c = p.calculated_stock
      public_total += p.product_price.price.to_f*stock_c
      public_count += stock_c if p.product_price.price.to_f > 0.00
      public_count_no_price += stock_c if p.product_price.price.to_f == 0.00
      
      supplier_total += p.product_price.supplier_price.to_f*stock_c
      supplier_count += stock_c if p.product_price.supplier_price.to_f > 0.00
      supplier_count_no_price += stock_c if p.product_price.supplier_price.to_f == 0.00
    end
    
    return { public_count: public_count,
            public_total: public_total,
            public_count_no_price: public_count_no_price,
            
            supplier_count: supplier_count,
            supplier_total: supplier_total,
            supplier_count_no_price: supplier_count_no_price
          }
  end
  
  def self.total_items_count
  end
  
  def self.update_all_public_prices
    self.all.each do |p|
      if p.product_price.supplier_price.to_f > 0.00
        new_price = p.product_price.dup
        new_price.price = 0.00
        new_price.calculate_price
        
        if new_price.price != p.product_price.price || new_price.supplier_price != p.product_price.supplier_price || new_price.supplier_id != p.product_price.supplier_id || new_price.customer_id != p.product_price.customer_id
          new_price.save
        else
          p.product_price.update_attribute("updated_at",Time.now)
        end

      end      
    end
  end
  
  def update_cache_stock
    self.update_attribute(:stock, self.calculated_stock)
  end
  

  def update_cache_search
    str = []
    str << display_name.to_s.downcase.strip
    str << description.to_s.downcase.strip
    
    self.update_column(:cache_search, str.join(" "))
  end
  
end
