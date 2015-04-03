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
  
  has_many :product_prices, :dependent => :destroy
  
  
  has_many :product_parts
  has_many :parts, :through => :product_parts, :source => :part
  
  accepts_nested_attributes_for :product_parts, :reject_if => lambda { |c| c[:part_id].blank? }

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
    
    return result
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
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.display_name} }
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
    
    where = "true"    
    where += " AND products.manufacturer_id IN (#{params["manufacturers"]})" if !params["manufacturers"].empty?
    where += " AND categories.id = #{params["category"]}" if !params["category"].empty?

    @products = self.joins(:categories).joins(:manufacturer).where(where)
    @products = @products.search(params["search"]["value"]) if !params["search"]["value"].empty?    
    @products = @products.order(order) if !order.nil?

    @products = @products.limit(params[:length]).offset(params["start"])
    data = []
    @products.each do |product|
      
      edit_link = '<a href="'+Rails.application.routes.url_helpers.edit_product_path(product)+'" class="btn btn-info btn-xs btn-mini">Edit</a> '
      update_price_link = link_helper.link_to('Price', {controller: "products", action: "update_price", id: product.id}, class: "btn btn-info btn-xs btn-mini")
      
      item = ['<div class="checkbox check-default"><input id="checkbox#{product.id}" type="checkbox" value="1"><label for="checkbox#{product.id}"></label></div>',
              product.categories.first.name,
              product.manufacturer.name,
              product.name,
              '<div class="text-right">'+product.product_price.price_formated+'</div>',
              '<div class="text-center">'+product.stock.to_s+'</div>',
              edit_link+
              update_price_link+
              ' <a rel="nofollow" href="'+Rails.application.routes.url_helpers.product_path(product)+'" data-method="delete" data-confirm="Are you sure?" class="btn btn-danger btn-xs btn-mini">X</a>',
              #product.manufacturer_name,
              #product.name,
              #product.formated_price,
              ''
            ]
      data << item
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
    
    return {result: result, items: @products}
  end
  
  def serial_numbers_extracted
    arr = []
    
    if !serial_numbers.nil?
      serial_numbers.split("\r\n").each do |line|
        item = line.strip
        if item.length < 40 && item.length > 4
          arr << item
        end      
      end
    end
      
    return arr
  end
  
  def valid_serial_numbers
    if stock.present?
      return serial_numbers_extracted.count <= stock
    else
      return true
    end
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
    
    if new_price.price != product_price.price || new_price.supplier_price != product_price.supplier_price || new_price.supplier_id != product_price.supplier_id
      new_price.save
    end
    
  end
  
  def category
    categories.order("created_at DESC").first
  end
  
  def is_out_of_stock
    stock.nil? || stock == 0
  end
  
  def is_price_outdated
    # if empty stock for 30 days
    (is_out_of_stock && (Time.now.to_date - updated_at.to_date).to_i >= 30) || product_price.nil? || product_price.price.nil?
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
      i = p.stock/(self.product_parts.where(part_id: p.id).first.quantity).to_i
      if count > i
        count = i
      end      
    end
    return count
  end
  
  def combine_parts(quantity)
    if quantity.to_i <= max_combinable && quantity.to_i != 0
      com = Combination.new(product_id: self.id, stock_before: self.stock, quantity: quantity.to_i)
      
      parts.each do |p|
        num = self.product_parts.where(part_id: p.id).first.quantity.to_i*quantity.to_i
        new_stock = p.stock - num
        
        com_detail = com.combination_details.new(product_id: p.id, stock_before: p.stock, quantity: new_stock)
        
        p.update_attributes(stock: new_stock)
        
        com_detail.stock_after = Product.find(p.id).stock
      end
      
      n_stock = self.stock+quantity.to_i
      self.update_attributes(stock: n_stock)
      
      com.stock_after = Product.find(self.id).stock
      
      com.save
      
      return true
    else
      return false
    end
  end
  
  
end
