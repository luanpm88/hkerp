module ApplicationHelper
  def format_price(number, vn = false, round = false, precision = nil)
    prec = (number.to_f.round == number.to_f) ? 0 : 2
    prec = 0 if round
    
    if !precision.nil?
      prec = precision
    end
    
    
    if vn
      number_to_currency(number, precision: prec, separator: ",", unit: '', delimiter: ".")
    else
      number_to_currency(number, precision: prec, separator: ".", unit: '', delimiter: ",")
    end
  end
  
  def add_sign(number)
    number > 0 ? "+"+number.to_s : number.to_s
  end
  
  def render_order_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      
      group_1 = 0
      if can? :finish_order, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Finish Order', {controller: "orders", action: "finish_order", id: item.id}, data: { confirm: 'Are you sure?'})+'</li>'        
        group_1 += 1
      end
      if can? :pay_order, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Pay Order', {controller: "payment_records", action: "new", order_id: item.id})+'</li>'
        group_1 += 1
      end
      
      if can? :pay_tip, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Pay Tip', {controller: "payment_records", action: "pay_tip", order_id: item.id})+'</li>'
        group_1 += 1
      end
      
      if can? :pay_commission, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Pay Commission', {controller: "payment_records", action: "pay_commission", order_id: item.id})+'</li>'
        group_1 += 1
      end
      
      actions += '<li class="divider"></li>' if group_1 > 0
      
      group_3 = 0
      if can? :confirm_items, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Confirm Items", confirm_items_orders_path(:id => item.id), data: { confirm: 'Are you sure?' })+'</li>'
        group_3 += 1
      end
      if can? :update_price, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Confirm Price", confirm_price_orders_url(id: item.id), data: { confirm: 'Are you sure?' })+'</li>'
        group_3 += 1
      end
      if can? :confirm_order, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Confirm Order", confirm_order_orders_path(:id => item.id), data: { confirm: 'Are you sure?' })+'</li>'
        group_3 += 1
      end
      if can? :change, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Change Items", change_orders_path(:id => item.id))+'</li>'
        group_3 += 1
      end      
      if can? :update_info, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Update Info", update_info_orders_path(:id => item.id, page: params[:page]))+'</li>'
        group_3 += 1
      end
      if can? :update_tip, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Update Tip', {controller: "orders", action: "update_tip", id: item.id})+'</li>'
        group_1 += 1
      end
      
      actions += '<li class="divider"></li>' if group_3 > 0
      
      
      group_4 = 0
      if can? :deliver, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Deliver', {controller: "deliveries",action: "deliver", order_id: item.id})+'</li>'
        group_4 += 1
      end
            
      actions += '<li class="divider"></li>' if group_4 > 0
      
      
      
      group_5 = 0
      if can? :read, Delivery
        if item.all_deliveries.count > 0
		  item.all_deliveries.each do |delivery|
            actions += '<li>'
            actions += ActionController::Base.helpers.link_to("<i class=\"icon-print\"></i>".html_safe+" Delivery ("+delivery.created_at.strftime("%Y-%m-%d")+")", {controller: "deliveries",action: "show", id: delivery.id, :export_ticket => true}, :class => 'fancybox.iframe ajax_iframe')
            actions += '</li>'
		  end
		  
		  group_5 += 1
		end
	  end
      
      actions += '<li class="divider"></li>' if group_5 > 0
      
      
      group_2 = 0
      if can? :read, PaymentRecord
        if item.all_order_payments.count > 0
		  item.all_order_payments.each do |recept|
            actions += '<li>'
            actions += ActionController::Base.helpers.link_to("<i class=\"icon-print\"></i>".html_safe+" Recept ("+recept.created_at.strftime("%Y-%m-%d")+")", recept, :class => 'fancybox.iframe ajax_iframe')
            actions += '</li>'
		  end		  
		  group_2 += 1
		end
        
        if item.all_tip_payments.count > 0
		  item.all_tip_payments.each do |recept|
            actions += '<li>'
            actions += ActionController::Base.helpers.link_to("<i class=\"icon-print\"></i>".html_safe+" Tip ("+recept.created_at.strftime("%Y-%m-%d")+")", recept, :class => 'fancybox.iframe ajax_iframe')
            actions += '</li>'
		  end		  
		  group_2 += 1
		end
	  end
      
      actions += '<li class="divider"></li>' if group_2 > 0
      
      
      group_6 = 0
      if can? :read_commissions, item
        if item.all_commission_payments.count > 0
		  item.all_commission_payments.each do |recept|
            actions += '<li>'
            actions += ActionController::Base.helpers.link_to("<i class=\"icon-print\"></i>".html_safe+" Commission ("+recept.created_at.strftime("%Y-%m-%d")+")", recept, :class => 'fancybox.iframe ajax_iframe')
            actions += '</li>'
		  end		  
		  group_6 += 1
		end
	  end
      
      actions += '<li class="divider"></li>' if group_6 > 0
      
      if can? :order_log, item
        actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon-time\"></i> Order Logs".html_safe, {controller: "orders", action: "order_log", id: item.id}, title: "Order Logs", target: "_blank")+'</li>'
      end
      if can? :show, item
        actions += '<li>'+ActionController::Base.helpers.link_to("View", item, title: "Edit Order", class: "fancybox.iframe show_order")+'</li>'
      end
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Edit", edit_order_path(item), title: "Edit Order")+'</li>'
      end
      if can? :destroy, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Delete", item, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'
      end
      if can? :read, item
        actions += '<li>'+ActionController::Base.helpers.link_to('PDF', download_pdf_orders_path(:id => item.id), :target => "_blank")+'</li>'
      end
      if can? :print_order, item       
        actions += '<li>'+ActionController::Base.helpers.link_to('Print Order (raw)', print_order_orders_path(:id => item.id), :target => "_blank")+'</li>'
      end
      
      if can? :print_order_fix1, item       
        actions += '<li>'+ActionController::Base.helpers.link_to('Print Order (raw) Fix1', print_order_fix1_orders_path(:id => item.id), :target => "_blank")+'</li>'
      end
     
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_custom_payments_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      
      group_1 = 0
      if can? :edit_pay_custom, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "payment_records", action: "edit_pay_custom", id: item.id})+'</li>'        
        group_1 += 1
      end
      if can? :destroy, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Delete', item, method: :delete, data: { confirm: 'Are you sure?'})+'</li>'        
        group_1 += 1
      end      
      
      #actions += '<li class="divider"></li>' if group_1 > 0
      
      
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def get_months_between_time(from_date, to_date)
	months = []

	(from_date.year..to_date.year).each do |y|
	  mo_start = (from_date.year == y) ? from_date.month : 1
	  mo_end = (to_date.year == y) ? to_date.month : 12
   
	  (mo_start..mo_end).each do |m|  
		months << "#{y.to_s}-#{m.to_s}-01".to_date
	  end
	end
	
	return months
  end
  
  def render_users_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "users", action: "edit", id: item.id})+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
