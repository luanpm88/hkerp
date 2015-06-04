class CustomerPo < ActiveRecord::Base
  include PgSearch
  
  has_and_belongs_to_many :orders
  
  validates :code, presence: true, :uniqueness => true
  validates :filename, presence: true
  
  mount_uploader :filename, ProductUploader
  
  belongs_to :user
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.order("created_at DESC")
    
    @records = @records.where(user_id: user.id)
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 6
    
    @records.each do |item|
      item.orders.each do |order|
        line = [
              link_helper.link_to(item.code, {controller: "orders", action: "show", id: order.id}, class: "fancybox.iframe show_order main-title")+order.display_description,
              '<div class="text-left">'+link_helper.link_to("#{item.code}.pdf", item.file, target: "_blank")+'</div>',
              '<div class="text-center">'+order.salesperson.name+'</div>',
              "<div class=\"text-center\">#{order.display_delivery_status}</div>",
              "<div class=\"text-center\">#{order.display_payment_status}</div>",
              "<div class=\"text-center\">#{order.display_status}</div>",
              '',
            ]
        data << line
      end
        
        
      if item.orders.empty?
          line = [
            item.code,              
            '<div class="text-left">'+link_helper.link_to("#{item.code}.pdf", item.file, target: "_blank")+'</div>',
            '<div class="text-center">'+item.user.name+'</div>',
            "<div class=\"text-center\"></div>",
            "<div class=\"text-center\"></div>",
            "<div class=\"text-center\"></div>",
            '',
          ]
          data << line
      end       
      
      
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @records, actions_col: actions_col}
  end
  
  def file_path(version = nil)
    if !self.filename_url.nil?
      return self.filename_url
    else
      return nil
    end
  end
  
  def file(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.url_for(controller: "customer_pos", action: "file", id: self.id, type: version)
  end
  
  pg_search_scope :search,
                against: [:code],                
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(q)
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.code} }
  end
  
end
