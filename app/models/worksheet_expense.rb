class WorksheetExpense < ActiveRecord::Base
  include PgSearch
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_and_belongs_to_many :worksheets
  
  def self.full_text_search(q)
    self.where("LOWER(worksheet_expenses.name) LIKE ?", "%#{q.strip.downcase}%").limit(50).map {|model| {:id => model.id, :text => model.name} }
  include PgSearch  
  
  pg_search_scope :search,
              against: [:status, :type_name, :name],
              associated_against: {
                user: [:first_name, :last_name]
              },
              using: {
                tsearch: {
                  dictionary: 'english',
                  any_word: true,
                  prefix: true
                }
              }
  end
  
  def price=(new_price)
      self[:price] = new_price.to_s.gsub(/[\,]/, '')
  end
  
#  def self.search_expenses(params)
#      records = Expense.all
#      
#      if params[:order_by]=='none'
#          records = records
#      end
#      
#      if params[:order_by]=='all'
#          records = records.where(type_name: 'all')
#      end
#  
#      if params[:order_by]=='per_km'
#          records = records.where(type_name: 'per_km')
#      end
#      
#      if params[:order_by_cend] == 'asc'
#        records = records.order("expenses.created_at ASC")
#      end
#      
#      if params[:order_by_cend] == 'desc'
#        records = records.order("expenses.created_at DESC")
#      end
#      
#      return records
#  end
  

  def self.datatable(params, user)
      ActionView::Base.send(:include, Rails.application.routes.url_helpers)
      link_helper = ActionController::Base.helpers    
      
      @records = self.all
      
      if !params["order"].nil?
        if params["order"]["0"]["column"]="5"
          @records = @records.order("created_at #{params["order"]["0"]["dir"]}")
        end
        if params["order"]["0"]["column"]="1"
          @records = @records.order("name #{params["order"]["0"]["dir"]}")
        end
      end
#      @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
      
      
      if !params.nil?
        if params[:status].present? && params[:status] == "active"
          @records = @records.where(status: "active")
        end
        if params[:status].present? && params[:status] == "deleted"
          @records = @records.where(status: "deleted")
        end
        if params[:status].present? && params[:status] == "all"
          @records = @records.all
        end
        ##
        if params[:type_name].present? && params[:type_name] == "per_worksheet"
          @records = @records.where(type_name: "per_worksheet")
        end
        if params[:type_name].present? && params[:type_name] == "per_kilometer"
          @records = @records.where(type_name: "per_kilometer")
        end
        if params[:type_name].present? && params[:type_name] == "all"
          @records = @records.all
        end
      end
      
      total = @records.count
      @records = @records.limit(params[:length]).offset(params["start"])
      data = []
      
      actions_col = 7
      @records.each do |item|
        row = [
                  "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
                  "<span class=\"main-name\">"+item.name+"</span>",
                  '<div class="text-center">'+item.price.to_i.to_s+"</div>",
                  '<div class="text-center">'+item.display_type_name+"</div>",
                  '<div class="text-center">'+item.description+"</div>",
                  '<div class="text-center">'+item.created_at.strftime("%d/%m/%Y")+"</div>",
                  '<div class="text-center">'+item.display_status+"</div>",
                  item.creator.nil? ? "" : "<div class=\"text-center\">"+item.creator.staff_col+'</div>',
                  '',
              ]
        data << row
        
      end
      
      result = {
                "drawn" => params[:drawn],
                "recordsTotal" => total,
                "recordsFiltered" => total
      }
      result["data"] = data
      
      return {result: result, items: @records, actions_col: actions_col}
  end
  
  def display_type_name
    if self.type_name == 'per_worksheet'
      return "Per Worksheet"
    elsif self.type_name == 'per_kilometer'
      return "Per Kilometer"
    end
  end
  
  def display_status
    return "<div class=\"#{self.status}\">#{self.status}</div>".html_safe
  end

end
