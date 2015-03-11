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
      item = ['<div class="checkbox check-default"><input id="checkbox#{product.id}" type="checkbox" value="1"><label for="checkbox#{product.id}"></label></div>',
              product.categories.first.name,
              product.manufacturer.name,
              product.name,
              product.formated_price,
              '<a href="'+Rails.application.routes.url_helpers.edit_product_path(product)+'" class="btn btn-info btn-xs btn-mini"><i class="icon-paste"></i></a>'+
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
    
    return result
  end
  
end
