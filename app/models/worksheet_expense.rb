class WorksheetExpense < ActiveRecord::Base
  include PgSearch
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_and_belongs_to_many :worksheets
  
  def self.full_text_search(q)
    self.where("LOWER(worksheet_expenses.name) LIKE ?", "%#{q.strip.downcase}%").limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def price=(new_price)
      self[:price] = new_price.to_s.gsub(/[\,]/, '')
  end
  
  def self.search_expenses(params)
      records = Expense.all
      
      if params[:order_by]=='none'
          records = records
      end
      
      if params[:order_by]=='all'
          records = records.where(type_name: 'all')
      end
  
      if params[:order_by]=='per_km'
          records = records.where(type_name: 'per_km')
      end
      
      if params[:order_by_cend] == 'asc'
        records = records.order("expenses.created_at ASC")
      end
      
      if params[:order_by_cend] == 'desc'
        records = records.order("expenses.created_at DESC")
      end
      
      return records
  end
  
  def self.datatable(params, user)
      ActionView::Base.send(:include, Rails.application.routes.url_helpers)
      link_helper = ActionController::Base.helpers    
      
      @records = self.all
      
      if !params[:type_name].present? && params[:type_name] == 'all'
        @records = @records.where(type_name: 'all')
      elsif !params[:type_name].present? && params[:type_name] == 'per_km'
        @records = @records.where(type_name: 'per_km')
      end
      
      total = @records.count
      @records = @records.limit(params[:length]).offset(params["start"]).where(status: 'active' )
      data = []
      
      actions_col = 8
      @records.each do |item|
        row = [
                  "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
                  "<span class=\"main-name\">"+item.name+"</span>",
                  '<div class="text-center">'+item.price.to_i.to_s+"</div>",
                  '<div class="text-center">'+item.display_type_name+"</div>",
                  '<div class="text-center">'+item.description+"</div>",
                  '<div class="text-center">'+item.created_at.strftime("%Y-%m-%d")+"</div>",
                  '<div class="text-center">'+item.status+"</div>",
                  item.creator.nil? ? "" : "<div class=\"text-center\">"+item.creator.short_name+'</div>',
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
    if self.type_name == 'all'
      return "All"
    elsif self.type_name == 'per_km'
      return "Per Kilometer"
    end
  end

end
