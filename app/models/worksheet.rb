class Worksheet < ActiveRecord::Base
  include PgSearch
  belongs_to :creator, class_name: "User"
  
  has_and_belongs_to_many :users
  has_and_belongs_to_many :worksheet_expenses
  
  has_many :worksheet_intineraries, dependent: :destroy
  has_many :worksheets_worksheet_expenses, dependent: :destroy
  has_many :users_worksheets, dependent: :destroy
  
  accepts_nested_attributes_for :worksheets_worksheet_expenses, :reject_if => lambda { |a| a[:worksheet_expense_id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :users_worksheets, :reject_if => lambda { |a| a[:user_id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :worksheet_intineraries, :reject_if => lambda { |a| a[:start_address].blank? }, :allow_destroy => true

  pg_search_scope :search,
                against: [:status],
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.order("created_at DESC")
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
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
    end
    
    if params["from_date"].present?
      @records = @records.where("worksheets.created_at >= ?", params["from_date"].to_datetime.beginning_of_day)
    end
    
    if params["to_date"].present?
      @records = @records.where("worksheets.created_at <= ?", params["to_date"].to_datetime.end_of_day)
    end
    
    if params[:user_id].present?
        @records = @records.joins(:users).where(users: {id: params[:user_id]})
    end
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 4
    @records.each do |item|
      
      trashed_class =  item.status == "deleted" ? "trashed" : ""
      row = [
              "<strong class=\"text-left #{trashed_class}\">"+item.display_user_name.join("<br/>")+"</strong>",
              "<div class=\"text-center #{trashed_class}\">"+item.display_status+"</div>",
              "<div class=\"text-center #{trashed_class}\">"+item.created_at.strftime("%d/%m/%Y")+"</div>",
              "<div class=\"text-center\">"+item.creator.staff_col+"</div>",
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
  
  def display_user_name
    arr = []
    users.each do |user|
      arr << user.name
    end
    
    return arr
  end
  
  def get_creator_name
    self.users.where("worksheets.creator_id = users.id")
  end
  
  def trash
    self.update_attribute(:status, 0)
  end
  
  def un_trash
    self.update_attribute(:status, 1)
  end
  
  def trash
    self.update_attribute(:status, "deleted")
  end
  
  def un_trash
    update_attributes(status: "active")
  end
  
  def display_status
    return "<div class=\"#{self.status}\">#{self.status}</div>".html_safe
  end
  
end
