class Feedback < ActiveRecord::Base
  include PgSearch
  
  mount_uploader :image, ImageUploader
  
  belongs_to :user
  
  pg_search_scope :search,
                against: [:title, :content],                
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
    
    @records = self.all    
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !user.has_role?("admin")
      @records = @records.where(user_id: user.id)
    end
    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 5
    @records.each do |item|
      item = [
              "<span class=\"main-title\">"+item.title+"</span>"+item.content,
              "<div class=\"text-center\"><a class=\"fancybox_image\" href=\"#{item.picture}.png\"><img src=\"#{item.picture(:thumb)}\" width=\"60\" /></a></div>",
              '<div class="text-center">'+item.created_at.strftime("%Y-%m-%d")+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
              '<div class="text-center">'+item.display_status(user.has_role?("admin"))+"</div>",
              '',
            ]
      data << item
      
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @records, actions_col: actions_col}
  end
  
  def display_status(is_link)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    url = is_link ? link_helper.url_for({controller: "feedbacks", action: "check", value: !(self.status==1), id: self.id}) : ""
    
    ApplicationController.helpers.check_ajax_button(self.status==1, url)
  end
  
  def picture_path(version = nil)
    if self.image_url.nil?
      return "public/img/avatar.jpg"
    elsif !version.nil?
      return self.image_url(version)
    else
      return self.image_url
    end
  end
  
  def picture(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.url_for(controller: "feedbacks", action: "picture", id: self.id, type: version)
  end
  
end
