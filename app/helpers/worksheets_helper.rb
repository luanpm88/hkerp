module WorksheetsHelper
  
  def render_worksheet_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      if item.status == "active"
        if can? :show, item
          actions += '<li>'+ActionController::Base.helpers.link_to('View', {controller: "worksheets", action: "show", id: item.id, tab_page: 1}, psrc: worksheets_path(tab_page: 1), title: "View Worksheet Details", class: "tab_page")+'</li>'
        end
        
        if can? :update, item
          actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "worksheets", action: "edit", id: item.id, tab_page: 1}, psrc: worksheets_path(tab_page: 1), title: "Edit Worksheet", class: "tab_page")+'</li>'        
        end
      
        if can? :trash, item
          actions += '<li>'+view_context.link_to('<i class="icon-trash"></i> Trash'.html_safe, {controller: "worksheets", action: "trash", id: item.id, tab_page: 1}, method: :patch)+'</li>'
        end
      end
      
      if item.status == "deleted"
        if can? :destroy, item
          actions += '<li>'+ActionController::Base.helpers.link_to("Delete", item, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'
        end
        
        if can? :un_trash, item
          actions += '<li>'+view_context.link_to('<i class="icon-trash"></i> Un-Trash'.html_safe, {controller: "worksheets", action: "un_trash", id: item.id, tab_page: 1}, method: :patch)+'</li>'
        end
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
end
