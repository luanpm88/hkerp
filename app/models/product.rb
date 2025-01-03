class Product < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include PgSearch

  after_save :update_cache_search
  after_save :update_cache_web_search

  after_save :update_cache_last_ordered
  after_save :update_cache_last_priced
  
  after_save :update_cache_display_name

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
  
  def listed_price=(new_price)
    self[:listed_price] = new_price.to_s.gsub(/[\,]/, '')
  end
  
  def discount_percent
    return 0 if listed_price.to_f == 0
    ((listed_price.to_f - product_price.price.to_f)/listed_price.to_f) * 100
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

  def web_price=(new_price)
    self[:web_price] = new_price.to_s.gsub(/[\,]/, '')
  end

  def display_name
    # if fixed_name.present?
    #   return fixed_name
    # end

    result = ''
    if categories.first.present? and categories.first.name.downcase != 'none'
      result += categories.first.name + " "
    end

    if manufacturer.present? and manufacturer.name.downcase != 'none'
      result += manufacturer.name + " "
    end


    result += name
    result += " (#{product_code.to_s.strip})" if product_code.present? and product_code.to_s.strip.present?

    return result.strip
  end
  
  def update_cache_display_name
    update_column(:cache_display_name, self.display_name)
  end

  def display_name_without_category
    result = ''

    if manufacturer.present? and manufacturer.name.downcase != 'none'
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
    result = self.where(status: 1)

    q.split(" ").each do |k|
      result = result.where("(LOWER(products.cache_search) LIKE ? OR products.cache_search LIKE ?)", "%#{k.strip.downcase}%", "%#{k.strip}%")
    end

    result = result.limit(50).map {|model| {:id => model.id, :text => model.display_name} }
    return result
  end

  def self.filter(params, user)
    if params["status"].present? and params["status"] == 'deleted'
        where = "products.status=0"
    else
        where = "products.status=1"
    end
    where += " AND products.manufacturer_id IN (#{params["manufacturers"].join(",")})" if params["manufacturers"].present? # && !params["search"]["value"].present?
    where += " AND categories.id IN (#{params["categories"]})" if params["categories"].present? # && (!params["search"].present? || !params["search"]["value"].present?)

    @products = self.joins(:categories).joins(:manufacturer).where(where)
    # @products = @products.search(params["search"]["value"]) if params["search"]["value"].present?

    if params["search"].present? && params["search"]["value"].present?
      params["search"]["value"].split(" ").each do |k|
        @products = @products.where("(LOWER(products.cache_search) LIKE ? OR products.cache_search LIKE ?)", "%#{k.strip.downcase}%", "%#{k.strip}%") if k.strip.present?
      end
    end

    if params["status"].present?
      if params["status"] == 'suspended'
         @products = @products.where(suspended: true)
      elsif params["status"] == 'not_suspended'
         @products = @products.where(suspended: false)
      elsif params["status"] == 'deleted'
          @products = @products.where('products.status = 0')
      end
    end
    
    if params["supplier_id"].present?
      @products = @products.where('products.cache_recent_supplier_ids LIKE ? OR products.cache_recent_supplier_ids LIKE ? OR products.cache_recent_supplier_ids LIKE ? OR products.cache_recent_supplier_ids LIKE ?', '%['+params["supplier_id"]+',%', '%,'+params["supplier_id"]+']%', '%,'+params["supplier_id"]+',%', '%['+params["supplier_id"]+']%')
    end
    
    if params["year"].present?
      @products = @products.where('extract(year from products.created_at) = ?', params["year"])
    end
    
    if params["month"].present?
      @products = @products.where('extract(month from products.created_at) = ?', params["month"])
    end
    
    if params["in_use"].present?
      @products = @products.where(in_use: params["in_use"])
    end
    
    @products = @products.where(user_id: params["user_id"]) if params["user_id"].present?


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

    @products = @products.order(order + ', products.created_at') if !order.nil?
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
                col_2 = product.name+" ("+product.product_code+")<br />"+product.product_log_link+"<div>"+product.description[0..80]+"</div>"
                col_3 = product.calculated_stock((from_date - 1.day).end_of_day).to_s

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

                col_8 = product.calculated_stock(to_date).to_s

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
                # supplier_price = user.can?(:view_supplier_price, product) ? product.product_price.supplier_price_formated : "####"
                
                suppliers = params["supplier_id"].present? ? product.display_suppliers(user) : ""

                trashed_class =  product.status == 0 ? "trashed" : ""
                item = [
                        "<div class=\"text-left #{trashed_class}\">"+product.categories.first.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\">"+product.manufacturer.name+'</div>',
                        "<div class=\"text-left #{trashed_class}\"><strong class=\"main-title\">"+product.name.to_s+" "+product.product_code.to_s+"</strong><div>"+product.description.to_s[0..80]+"<div>#{(product.note.present? ? "(#{product.note})": "")}</div></div>"+(!product.fixed_name.present? ? '' :"<div>Fixed name: "+product.fixed_name.to_s+"</div>")+(product.warranty.empty? ? '' :"<div>Warranty: "+product.warranty.to_s+"</div>") + suppliers.to_s + '</div>',
                        #"<div class=\"text-right #{trashed_class}\">"+supplier_price+'</div>',
                        "<div class=\"text-right #{trashed_class}\">"+product.price_col(user)+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.calculated_stock.to_s+'</div>',
                        "<div class=\"text-center #{trashed_class}\">"+product.display_status+product.price_status+product.suspended_status+product.in_use_status+'</div>',
                        "<div class=\"text-center\"><a class=\"fancybox_image\" href=\"#{product.image}.png\"><img src=\"#{product.image(:thumb)}\" width=\"60\" /></a></div>",
                        product.user.nil? ? "" : "<div class=\"text-center\">"+product.created_at.strftime("%Y-%m-%d")+"<br>By<br><div class=\"text-center\">"+product.user.staff_col+'</div></div>',
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
  
  def display_suppliers(user)
    if !user.can?(:view_suppliers, self)
      return ""
    end
    
    return "" if !cache_recent_supplier_ids.present?
    
    arr = Contact::where(id: JSON.parse(cache_recent_supplier_ids)).map(&:short_name)
    
    return "<br /><b>Suppliers</b>:<br /><div>" + arr.join("</div><div>") + "</div>"
  end

  def price_col(user)
    if user.can?(:update_price, self)
      html = "<div><div class='text-nowrap'>#{self.product_price.price_formated}</div>"
      # html += "<div class='text-nowrap'>P: #{self.product_price.supplier_price_formated}</div>"
      html += "<a class='price_box_toggle_btn' href='#update_price'><i class='icon-pencil'></i></a>"
      html += "<div class='update_price_box' data-id='#{self.id}'>
          <h5>Update price</h5>
          <p>Price is updated at: <strong>#{ self.product_price.updated_at.strftime('%Y-%m-%d') if self.product_price.updated_at.present?}</strong>, By: <strong>#{self.product_price.user.name if self.product_price.updated_at.present?}</strong>
          #{'<span class=\'text-danger\'>[not_auto]</span>' if self.is_manual_price_update == true}
          </p>
          <title>#{self.display_name}</title>          
          <label>Purchase: <span class='help'>(required)</span></label>
          <input value='"+self.product_price.supplier_price_formated+"' class='price_input' type='text' name='new_supplier_price' value='' />
          <label>Supplier: <span class='help'>(required)</span></label>
          <input text='"+self.product_price.supplier_name+"' value='"+self.product_price.supplier_id.to_s+"' name='supplier_id' data='/contacts.json' class='select2-ajax-suppliers' />
          <label>Sales:</label>
          <input class='price_input' type='text' name='new_price' value='' />
          <br>
          <a class='btn btn-primary btn-small btn-save' href='#save'>Save</a>
          <a class='btn btn-small btn-cancel' href='#save'>Cancel</a>
        </div>"
      html += "</div>"
      
      html += "<div>List Price: #{Order.format_price(self.listed_price.to_f)} <br>Discount: #{self.discount_percent.round(2)}%</div>" if self.listed_price.to_f != 0
      
      if self.product_price.present? and self.product_price.updated_at.present?
				html += "<span class='label label-success'>#{self.product_price.updated_at.strftime('%d-%m-%Y')}</span>"
			end

      html
    else
      self.product_price.price_formated
    end
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
  
  after_save :update_cache_price
  def update_cache_price
    update_column(:cache_price, product_price.price.to_f)
  end

  def update_price(params, user, change_public_price=true)
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

    if !user.can?(:update_public_price, self) and change_public_price
      new_price.price = nil
    end

    if !user.can? :update_price, self
      new_price.supplier_price = nil
      new_price.supplier_id = nil
    end

    # calculate public price
    new_price.calculate_price if !self.is_manual_price_update and (change_public_price || new_price.price.to_f == 0)

    if new_price.price != self.product_price.price || new_price.supplier_price != self.product_price.supplier_price || new_price.supplier_id != self.product_price.supplier_id || new_price.customer_id != self.product_price.customer_id
      new_price.save

      # API
      self.update_column(:erp_price_updated, false)
    else
      self.product_price.update_column("updated_at",Time.now) if self.product_price.id.present?
    end

    # API
    self.update_column(:erp_price_updated, false) if self.web_price.present? and self.web_price != self.product_price.price

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
    if (calculated_stock <= 0 && !product_price.updated_at.nil? && (Time.now.to_date - product_price.updated_at.to_date).to_i >= 180)
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

    return "<div class=\"#{status} price_update_status\">#{status}</div>".html_safe
  end

  def suspended_status
    return !suspended ? '' : "<div class=\"price_outdated\">suspended</div>".html_safe
  end
  
  def in_use_status
    return in_use ? '' : "<div class=\"text-danger\">unused</div>".html_safe
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



  def calculated_stock(datetime=nil)
    if !datetime.present?
      datetime = DateTime.now + 1.day
      realtime = true
    else
      datetime = datetime.beginning_of_day
      realtime = false
    end
    
    datetime = datetime.beginning_of_day
    
    count = 0
    #count for combinations
    count += combinations.where("combinations.created_at <= ?", datetime).where(combined: [nil,true]).sum(:quantity)-combination_details.joins(:combination).where("combinations.created_at <= ?", datetime).where(combinations: {combined: [nil,true]}).sum(:quantity)
    count += -combinations.where("combinations.created_at <= ?", datetime).where(combined: false).sum(:quantity)+combination_details.joins(:combination).where("combinations.created_at <= ?", datetime).where(combinations: {combined: false}).sum(:quantity)

    #count for sales delivery
    count -= delivery_details
                      .joins(:delivery)
                      .joins(:order_detail => :order)
                      .where(orders: {order_status_name: ["confirmed","finished"]})
                      .where(deliveries: {status: 1})
                      .where(orders: {parent_id: nil, supplier_id: Contact.HK.id})
                      .where("deliveries.delivery_date <= ?", datetime)
                      .sum(:quantity)

    #count for purchase delivery
    count += delivery_details
                      .joins(:delivery)
                      .joins(:order_detail => :order)
                      .where(orders: {order_status_name: ["confirmed","finished"]})
                      .where(deliveries: {status: 1})
                      .where(orders: {parent_id: nil, customer_id: Contact.HK.id})
                      .where("deliveries.delivery_date <= ?", datetime)
                      .sum(:quantity)

    #count for stock update
    count += stock_update_count(nil, datetime)

    if realtime && (self.stock.nil? || self.stock != count)
      self.update_columns(stock: count)
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
                      .joins(:order => :order_status)
                      .where(order_statuses: {name: ["confirmed","finished"]})
                      .where(orders: {parent_id: nil, supplier_id: Contact.HK.id})
                      .where("orders.order_date < ?", datetime)
                      .sum(:quantity)

    #count for purchase delivery
    count += order_details
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
    if from_date.present?
      result = result.where('created_at >= ?', from_date.beginning_of_day)
    end
    if to_date.present?
      result = result.where('created_at <= ?', to_date.end_of_day)
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
    Product.where(status: 1).joins(:categories, :manufacturer).order("categories.name, manufacturers.name")
  end

  def self.stock_statistics(from_date, to_date)
    Product.where(status: 1).joins(:categories, :manufacturer).order("categories.name, manufacturers.name, stock desc")
  end

  def self.stock_report(from_date, to_date)
    Product.where(status: 1).joins(:categories, :manufacturer)
  end
  
  def self.report(from_date, to_date, remain=true)
    products = self.statistics(from_date, to_date).limit(1000)

    data = {
      items: [],
      count: 0,
      total: {
        b: 0,
        b_price: 0,
        purchase: 0,
        sales: 0,
        combine: 0,
        io: 0,
        e: 0,
        e_price: 0,
      },
    }

    total = products.count.to_s

    products.each_with_index do |product, index|
      e = product.calculated_stock(to_date.end_of_day)
      
      purchase = product.import_count(from_date, to_date)
      sales = product.export_count(from_date, to_date)
      combine = product.combination_count(from_date, to_date)
      io = product.stock_update_count(from_date, to_date)          
      
      if remain.nil? || (!remain.nil? && (e > 0 || purchase > 0 || sales > 0 || combine > 0 || io > 0))
        b = product.calculated_stock((from_date - 1.day).end_of_day)
        e_price = product.cost_price(from_date).to_f * e
        b_price = product.cost_price(from_date).to_f * b

        # insert product
        data[:items] << {
          b: b,
          b_price: b_price,
          purchase: purchase,
          sales: sales,
          combine: combine,
          io: io,
          e: e,
          e_price: e_price,
        }
        
        # total
        data[:total][:b_price] += b_price
        data[:total][:b] += b
        data[:total][:purchase] += purchase
        data[:total][:sales] += sales
        data[:total][:combine] += combine
        data[:total][:io] += io
        data[:total][:e] += e
        data[:total][:e_price] += e_price
        
        # increment count
        data[:count] += 1
      end

      puts index.to_s + '/' + total.to_s
    end

    return data
  end

  def import_count(from_date=nil, to_date=nil)
    #products = order_details
    #          .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
    #          .where(order_statuses: {name: ["confirmed","finished"]})
    #          .where(orders: {parent_id: nil, customer_id: Contact.HK.id})
    #if from_date.present? && to_date.present?
    #  products = products.where('orders.order_date >= ?', from_date.beginning_of_day).where('orders.order_date <= ?', to_date.end_of_day)
    #end
    #
    #
    #count = products.sum("quantity")

    #count for purchase delivery
    counts = delivery_details
                      .joins(:delivery)
                      .joins(:order_detail => :order)
                      .where(orders: {order_status_name: ["confirmed","finished"]})
                      .where(deliveries: {status: 1})
                      .where(orders: {parent_id: nil, customer_id: Contact.HK.id})
                      
    if from_date.present? && to_date.present?
      counts = counts.where('deliveries.delivery_date >= ?', from_date.beginning_of_day).where('deliveries.delivery_date <= ?', to_date.end_of_day)
    end
    
    counts.sum("quantity")
  end



  def export_count(from_date=nil, to_date=nil)
    counts = delivery_details
                      .joins(:delivery)
                      .joins(:order_detail => :order)
                      .where(orders: {order_status_name: ["confirmed","finished"]})
                      .where(deliveries: {status: 1})
                      .where(orders: {parent_id: nil, supplier_id: Contact.HK.id})
                      
    if from_date.present? && to_date.present?
      counts = counts.where('deliveries.delivery_date >= ?', from_date.beginning_of_day).where('deliveries.delivery_date <= ?', to_date.end_of_day)
    end
    
    counts.sum("quantity")
  end

  def export_amount(from_date=nil, to_date=nil)
    products = order_details
              .joins(:order => :order_status) #.joins(:order_status).where(order_statuses: {name: ["items_confirmed"]})
              .where(order_statuses: {name: ["finished"]})
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
              .where(order_statuses: {name: ["finished"]})
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
              .where('deliveries.created_at >= ?', from_date)
              .where('deliveries.created_at <= ?', to_date)

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
    str << product_code.to_s.downcase.strip

    str << display_name.to_s.strip
    str << description.to_s.strip
    str << product_code.to_s.strip

    str << "[out_of_date]" if out_of_date

    self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
  end

  def update_cache_web_search
    str = []
    str << display_name.to_s.downcase.strip
    str << product_code.to_s.downcase.strip

    str << display_name.to_s.strip
    str << product_code.to_s.strip

    self.update_column(:cache_web_search, str.join(" ") + " " + str.join(" ").to_ascii)
  end

  # out of date condition
  def out_of_date
    last_order_detail = self.order_details.order("created_at DESC").first
    last_priced = self.product_prices.order("created_at DESC").first

    if last_order_detail.nil?
      last_date = self.updated_at
    else
      last_date = last_order_detail.updated_at
    end

    if last_priced.present?
      if last_date < last_priced.created_at
        last_date = last_priced.created_at
      end
    end

    return (self.stock <= 0 and last_date < Time.now - 6.months)
  end

  def get_web_price
    web_price.to_f > 0 ? web_price : self.product_price.price
  end

  def update_cache_last_ordered
    if !self.order_details.empty?
      update_column(:cache_last_ordered, self.order_details.order('updated_at DESC').first.updated_at)
    end
  end

  def update_cache_last_priced
    if !self.product_prices.empty?
      update_column(:cache_last_priced, self.product_prices.order('updated_at DESC').first.updated_at)
    end
  end
  
  after_create :create_alias
  
  def create_alias
    name = self.display_name
    self.update_column(:alias, name.unaccent.downcase.to_s.gsub(/[^0-9a-z ]/i, '').gsub(/ +/i, '-').strip)
  end

  # refresh price
  def refresh_price(user)
    if !product_price.id.nil?
      new_p = product_price.dup
      new_p.user_id = user.id
      new_p.save
    end
  end
  
  # def BHPhotoVideo
  def self.bhpv_list(options={})
    response = RestClient.get options[:url], {params: options[:params]}
    html = response.body
    page = Nokogiri::HTML(html)
    
    page_num = page.css('.pagination p.pageNuber').text
    page_num = page_num.split("|").first.gsub(/\s+/, '/').split('/').last(2).first
    
    return page_num
    
    #items = page.css('.main-content .items .item')
    #
    #list = []
    #
    #items.each do |item|
    #  row = {
    #    name: item.css('span[itemprop=name]').text.strip,
    #    url: item.css('a[itemprop=url]').first['href'].strip,
    #    price: item.css('span[data-selenium=price]').text.strip,
    #    sku: item.css('span[data-selenium=sku]').text.strip,
    #  }
    #  
    #  list << row
    #end
    #
    #list
  end
  
  def has_parts?
    parts.count > 0
  end
  
  def recent_supplier_ids
    # Order.purchase_orders.joins(:order_details).order('orders.order_date DESC').where(order_details: {product_id: self.id}).map(&:supplier_id).uniq
    self.product_prices.order('created_at desc').map(&:supplier_id).uniq
  end

  def update_cache_recent_supplier_ids
    self.update_column(:cache_recent_supplier_ids, self.recent_supplier_ids.to_json)
  end
  
  def calc_cost_price(datetime=nil)
    if !datetime.present?
      datetime = DateTime.now + 1.day
      realtime = true
    else
      datetime = (datetime - 1.day).end_of_day
      realtime = false
    end
    
    arr = []
    logs = []
    
    #combinations
    combinations.where("combinations.created_at <= ?", datetime).where(combined: [nil,true]).map do |com|
      arr << {
        note: 'Được ghép',
        datetime: com.created_at,
        quantity: com.quantity,
      }
    end
    combination_details.joins(:combination).where("combinations.created_at <= ?", datetime).where(combinations: {combined: [nil,true]}).map do |cd|
      arr << {
        note: 'Đem ghép',
        datetime: cd.created_at,
        quantity: -cd.quantity,
      }
    end
    combinations.where("combinations.created_at <= ?", datetime).where(combined: false).map do |cd|
      arr << {
        note: 'Tách ra',
        datetime: cd.created_at,
        quantity: -cd.quantity,
      }
    end
    combination_details.joins(:combination).where("combinations.created_at <= ?", datetime).where(combinations: {combined: false}).map do |cd|
      arr << {
        note: 'Được tách',
        datetime: cd.created_at,
        quantity: cd.quantity,
      }
    end
    
    # sales delivery
    delivery_details
      .joins(:delivery)
      .joins(:order_detail => :order)
      .where(orders: {order_status_name: ["confirmed","finished"]})
      .where(deliveries: {status: 1})
      .where(orders: {parent_id: nil, supplier_id: Contact.HK.id})
      .where("deliveries.delivery_date <= ?", datetime).map do |cd|
        arr << {
          note: 'Bán hàng',
          datetime: cd.delivery.delivery_date,
          quantity: -cd.quantity,
        }
      end
    
    #purchase
    delivery_details
      .joins(:delivery)
      .joins(:order_detail => :order)
      .where(orders: {order_status_name: ["confirmed","finished"]})
      .where(deliveries: {status: 1})
      .where(orders: {parent_id: nil, customer_id: Contact.HK.id})
      .where("deliveries.delivery_date <= ?", datetime).map do |cd|
        arr << {
          note: 'Mua hàng',
          datetime: (cd.delivery.delivery_date - 1.day).end_of_day,
          quantity: cd.quantity,
          price: cd.order_detail.price,
        }
      end
      
    #update stock
    product_stock_updates.where('created_at <= ?', datetime).map do |cd|
      arr << {
        note: 'Điều chỉnh kho',
        datetime: cd.created_at,
        quantity: cd.quantity,
      }
    end
    
    
    arr = arr.sort_by { |hsh| hsh[:datetime] }
    
    # calculating
    finalPrice = nil
    finalQuantity = 0
    arr.each do |item|
      if item[:price].present?
        if finalPrice.nil?
          finalPrice = item[:price]
        else
          if (item[:quantity] + finalQuantity) == 0
            finalPrice = (finalPrice + item[:price])/2
          else
            finalPrice = ((finalPrice*finalQuantity) + (item[:price]*item[:quantity])) / (item[:quantity] + finalQuantity)
          end
        end
      end
      
      stock_before = finalQuantity
      
      finalQuantity += item[:quantity]
      
      logs << {
        datetime: item[:datetime],
        note: item[:note],
        stock_before: stock_before,
        quantity: item[:quantity],
        purchase_price: item[:price].to_f,
        stock_after: finalQuantity,
        cost_price: finalPrice.to_f,
      }
    end
    
    return {finalPrice: finalPrice, logs: logs}
  end
  
  def cost_price(datetime=nil)
    return calc_cost_price[:finalPrice]
  end

  def has_price
    #return false if self.categories.map(&:id).include?(8) || self.suspended == true
    return false if self.suspended == true
    return false if self.is_price_outdated
    self.cache_price.to_i != 0 and !self.no_price
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

    # if product_price.supplier_id.nil?
    #    return true
    # end

    # if empty stock for 30 days
    if (stock <= 0 && !product_price.updated_at.nil? && (Time.now.to_date - product_price.updated_at.to_date).to_i >= 180)
      return true
    end

    return false
  end


  # after_save :updateThcnInfo
  def updateThcnInfo
    begin
      logger.info('https://timhangcongnghe.com/hkerp/product-info/' + self.id.to_s)
      Net::HTTP::get(URI('https://timhangcongnghe.com/hkerp/product-info/' + self.id.to_s))
    rescue => e
      logger.error(e);
    end
  end

  def self.updateThcnInfoLast500
    ProductPrice.order('updated_at desc').limit(500).each do |pp|
      pp.product.updateThcnInfo
    end
  end

  def is_new
    return self.created_at > (Time.now - 30.days)
  end

end
