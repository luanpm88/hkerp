module ContactsHelper
  
  def render_contacts_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "contacts", action: "edit", id: item.id, tab_page: 1}, psrc: contacts_url(tab_page: 1), title: "Edit: #{item.short_name}", class: "tab_page")+'</li>'        
      end
      
      if can?(:inactive, item) and item.active
        actions += '<li>'+view_context.link_to('<i class="icon-trash"></i> Trash'.html_safe, {controller: "contacts", action: "inactive", id: item.id, tab_page: 1}, method: :patch)+'</li>'
      end
      if can?(:active, item) and !item.active
        actions += '<li>'+view_context.link_to('<i class="icon-trash"></i> Un-Trash'.html_safe, {controller: "contacts", action: "active", id: item.id, tab_page: 1}, method: :patch)+'</li>'
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
