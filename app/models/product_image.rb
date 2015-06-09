class ProductImage < ActiveRecord::Base
  mount_uploader :filename, ProductUploader
  
  belongs_to :product
  
  
  def image_path(version = nil)
    if self.filename_url.nil?
      return "public/img/photo.png"
    elsif !version.nil?
      return self.filename_url(version)
    else
      return self.filename_url
    end
  end
  
  def image(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.url_for(controller: "product_images", action: "image", id: self.id, type: version)
  end
end
