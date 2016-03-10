module WorksheetExpensesHelper
  def render_worksheet_expense_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      
      actions += '<li>'+ActionController::Base.helpers.link_to("View", {controller: "worksheet_expenses", action: "show", id: item.id, tab_page: 1}, title: "View - [#{item.id}]", class: "tab_page")+'</li>'
      
      actions += '<li>'+ActionController::Base.helpers.link_to("Edit", edit_worksheet_expense_path(id: item.id, tab_page: 1), psrc: (item.id ? worksheet_expenses_path(tab_page:1) : worksheet_expenses_url(tab_page: 1)), title: "Edit - [#{item.id}]", class: "tab_page")+'</li>'
      
      if item.status == "active"
        actions += '<li>'+ActionController::Base.helpers.link_to("Trash", delete_worksheet_expenses_path(id: item.id, tab_page: 1), psrc: (worksheet_expenses_path(tab_page: 1)), title: "Worksheet Expense - [#{item.id}]", class: "tab_page", data: { confirm: 'Are you sure?' })+'</li>'
      elsif item.status == "deleted"
        actions += '<li>'+ActionController::Base.helpers.link_to("Un-Trash", undo_deleted_worksheet_expenses_path(id: item.id, tab_page: 1), psrc: (worksheet_expenses_path(tab_page: 1)), title: "Worksheet Expense - [#{item.id}]", class: "tab_page", data: { confirm: 'Are you sure?' })+'</li>'
      end
            
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end 
end
