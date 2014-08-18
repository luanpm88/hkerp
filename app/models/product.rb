class Product < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include PgSearch
  
  validates :name, presence: true
  #validates :product_code, presence: true
  #validates :unit, presence: true
  validates :categories, presence: true
  validates :manufacturer, presence: true
  
  has_and_belongs_to_many :categories
  belongs_to :manufacturer
  belongs_to :user
  
  has_many :order_details
  
  def order_supplier_history
    @list = order_details.where("order_id IS NOT NULL").order("created_at DESC").limit(10)
    @html = "<ul>"
    @list.each do |item|
      @html += "<li>"+item.supplier.name+": <br />Price: <strong>"+item.formated_supplier_price+" VND</strong></li>";
    end
    @html += "</ul>";
    
    return @html
  end
  
  def formated_price
    number_to_currency(price, precision: 0, unit: '', delimiter: ".")
  end
  
  def price=(new_price)
    self[:price] = new_price.gsub(/\,/, '')
  end
  
  def display_name
    result = categories.first.name + " " + manufacturer.name + " " + name
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
    
    where = "true"
    where += " AND LOWER(products.name) LIKE '%#{params["search"]["value"].downcase}%'" if !params["search"]["value"].empty?
    where += " AND manufacturers.id IN (#{params["manufacturers"]})" if !params["manufacturers"].empty?
    where += " AND categories.id = #{params["category"]}" if !params["category"].empty?

    @products = Product.joins(:categories).joins(:manufacturer).select("DISTINCT manufacturers.name AS manufacturer_name, categories.name AS category_name, products.name, products.price").where(where).order(order).limit(params[:length]).offset(params["start"])
    data = []
    @products.each do |product|
      item = ['<div class="checkbox check-default"><input id="checkbox#{product.id}" type="checkbox" value="1"><label for="checkbox#{product.id}"></label></div>',
              product.category_name,
              product.manufacturer_name,
              product.name,
              product.formated_price,
              ''
            ]
      data << item
    end 
    
    total = Product.joins(:categories).joins(:manufacturer).select("DISTINCT manufacturers.name AS manufacturer_name, categories.name AS category_name, products.name, products.price").where(where).count("products.id");
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return result
  end
  
end
