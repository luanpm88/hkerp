module FeedbacksHelper
  
  def render_feedback_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "feedbacks", action: "edit", id: item.id, tab_page: 1})+'</li>'        
      end

      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
end
