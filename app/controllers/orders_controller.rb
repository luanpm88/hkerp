class OrdersController < ApplicationController
  load_and_authorize_resource :except => [:datatable]
  
  before_action :set_order, only: [:update_tip, :do_update_tip,  :order_log, :finish_order, :update_info, :do_update_info, :confirm_price, :do_update_price, :update_price, :do_change, :change, :pdf_preview, :show, :edit, :update, :destroy, :download_pdf, :print_order, :confirm_order]

  # GET /orders
  # GET /orders.json
  def index
    #Find Customer orders
    @orders = Order.customer_orders
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @hk = @order.supplier
    render :layout => nil
  end

  # GET /orders/new
  def new   
      @order = Order.new
      @order.order_date = (Time.now).strftime("%Y-%m-%d")
      @order.order_deadline = (Time.now + 7.days).strftime("%Y-%m-%d")
      #@order.payment_deadline = (Time.now + 3.days).strftime("%Y-%m-%d")
      @order.debt_date = (Time.now + 14.days).strftime("%Y-%m-%d")
      @order.debt_days = ((Time.now + 14.days).to_date - Time.now.to_date).to_i
      @order.shipping_date = (Time.now).strftime("%Y-%m-%d")
      @order.warranty_place = "Tận nơi"
      @order.warranty_cost = "0"
      if !params[:purchase].nil?
        @order.customer = Contact.HK
      else
        @order.supplier = Contact.HK
      end

  end

  # GET /orders/1/edit
  def edit
      @order.order_date = (@order.order_date).strftime("%Y-%m-%d")
      @order.order_deadline = (@order.order_deadline).strftime("%Y-%m-%d")
      #@order.payment_deadline = (@order.payment_deadline).strftime("%Y-%m-%d")
      @order.debt_date = (@order.debt_date).strftime("%Y-%m-%d") if !@order.debt_date.nil?
      @order.debt_days = (@order.debt_date.to_date - @order.order_date.to_date).to_i if !@order.debt_date.nil?
      @order.shipping_date = (@order.shipping_date).strftime("%Y-%m-%d")
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    
    @order.create_quotation_code
    
    if @order.is_purchase
      @order.purchase_manager = current_user
    end
    if @order.is_sales
      @order.salesperson = current_user
    end
    
    order_details_params = params[:order_details]
    if !order_details_params.nil?
        order_details_params.each do |line|
        od = OrderDetail.new(line[1])      
        @order.order_details << od
      end
    end
    
    p @order.order_details    
    
    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path
    respond_to do |format|
      if @order.save
        @order.set_status('new', current_user)
        if !@order.is_purchase
          format.html { redirect_to list_path, notice: 'Order was successfully created.' }
          format.json { render action: 'show', status: :created, location: @order }
        else
          format.html { redirect_to purchase_orders_orders_path, notice: 'Order was successfully created.' }
          format.json { render action: 'show', status: :created, location: @order }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path
    @order.save_draft(current_user)
      respond_to do |format|
        if @order.update(order_params)          
          @order.update_order_details(params[:order_details])
          
          if !params[:confirm].nil?
            format.html { redirect_to confirm_order_orders_url(id: @order.id) }
            format.json { head :no_content }
          else
            format.html { redirect_to list_path, notice: 'Order was successfully updated.' }
            format.json { head :no_content }
          end          
        else
          format.html { render action: 'edit' }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end
  
  def download_pdf
    @hk = @order.supplier
    
    render  :pdf => "order_"+@order.quotation_code,
            :template => 'orders/show.pdf.erb',
            :layout => nil,
            :footer => {
               :center => "",
               :left => "",
               :right => "",
               :page_size => "A4",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
  end
  
  def pdf_preview
    @hk = @order.supplier
    
    render layout: nil, template: 'orders/_show.html.erb'
  end
  
  def print_order
    authorize! :read, @order
    
    @hk = @order.supplier
    render  :pdf => "quotation_"+@order.quotation_code,
            :template => 'orders/print_order.pdf.erb',
            :layout => nil,
            :footer => {
                :center => "",
                :left => "",
                :right => "",
                :page_size => "A4",
                :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
    
    #render layout: false
  end
  
  def purchase_orders
    #Find Customer orders
    @orders = Order.purchase_orders
    
  end
  
  def confirm_order
    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path
    respond_to do |format|
      if @order.confirm_order(current_user)        
        format.html { redirect_to list_path, notice: 'Order was successfully confimed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_order_path(@order), alert: 'Order was unsuccessfully confimed. Check the order again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def confirm_items
    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path
    
    respond_to do |format|
      if @order.confirm_items(current_user)     
        format.html { redirect_to list_path, notice: 'Order Items was successfully confimed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_order_path(@order), alert: 'Order Items was unsuccessfully confimed. Check the order again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def confirm_price    
    respond_to do |format|
      if @order.confirm_price(current_user)      
        format.html { redirect_to pricing_orders_orders_url, notice: 'Order Prices was successfully confimed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to update_price_orders_url(id: @order.id), alert: 'Order Price was unsuccessfully confimed. Check the prices again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def finish_order
    
    respond_to do |format|
      if @order.finish_order(current_user)
        return_url = {controller: "accounting", action: "orders"}        
        format.html { redirect_to return_url, notice: 'Order was successfully finished.' }
        format.json { head :no_content }
      else
        format.html { redirect_to update_info_orders_path(:id => @order.id, accounting: true), alert: 'Order was unsuccessfully finished. You must update printed order number.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def datatable
    authorize! :view_list, Order
    
    result = Order.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      
      
      actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      
      group_1 = 0
      if can? :finish_order, item
        actions += '<li>'+view_context.link_to('Finish Order', {controller: "orders", action: "finish_order", id: item.id}, data: { confirm: 'Are you sure?'})+'</li>'        
        group_1 += 1
      end
      if can? :pay_order, item
        actions += '<li>'+view_context.link_to('Pay Order', {controller: "payment_records", action: "new", id: item.id})+'</li>'
        group_1 += 1
      end
      
      if can? :pay_tip, item
        actions += '<li>'+view_context.link_to('Pay Tip', {controller: "payment_records", action: "pay_tip", order_id: item.id})+'</li>'
        group_1 += 1
      end
      
      actions += '<li class="divider"></li>' if group_1 > 0
      
      group_3 = 0
      if can? :confirm_items, item
        actions += '<li>'+view_context.link_to("Confirm Items", confirm_items_orders_path(:id => item.id), data: { confirm: 'Are you sure?' })+'</li>'
        group_3 += 1
      end
      if can? :update_price, item
        actions += '<li>'+view_context.link_to("Confirm Price", confirm_price_orders_url(id: item.id), data: { confirm: 'Are you sure?' })+'</li>'
        group_3 += 1
      end
      if can? :confirm_order, item
        actions += '<li>'+view_context.link_to("Confirm Order", confirm_order_orders_path(:id => item.id), data: { confirm: 'Are you sure?' })+'</li>'
        group_3 += 1
      end
      if can? :change, item
        actions += '<li>'+view_context.link_to("Change Items", change_orders_path(:id => item.id))+'</li>'
        group_3 += 1
      end      
      if can? :update_info, item
        actions += '<li>'+view_context.link_to("Update Info", update_info_orders_path(:id => item.id, page: params[:page]))+'</li>'
        group_3 += 1
      end
      if can? :update_tip, item
        actions += '<li>'+view_context.link_to('Update Tip', {controller: "orders", action: "update_tip", id: item.id})+'</li>'
        group_1 += 1
      end
      
      actions += '<li class="divider"></li>' if group_3 > 0
      
      
      group_4 = 0
      if can? :deliver, item
        actions += '<li>'+view_context.link_to('Deliver', {controller: "deliveries",action: "deliver", order_id: item.id})+'</li>'
        group_4 += 1
      end
            
      actions += '<li class="divider"></li>' if group_4 > 0
      
      
      
      group_5 = 0
      if can? :read, Delivery
        if item.all_deliveries.count > 0
		  item.all_deliveries.each do |delivery|
            actions += '<li>'
            actions += view_context.link_to("<i class=\"icon-print\"></i>".html_safe+" Delivery ("+delivery.created_at.strftime("%Y-%m-%d")+")", {controller: "deliveries",action: "show", id: delivery.id, :export_ticket => true}, :class => 'fancybox.iframe ajax_iframe')
            actions += '</li>'
		  end
		  
		  group_5 += 1
		end
	  end
      
      actions += '<li class="divider"></li>' if group_5 > 0
      
      
      group_2 = 0
      if can? :read, PaymentRecord
        if item.all_payment_records.count > 0
		  item.all_payment_records.each do |recept|
            actions += '<li>'
            actions += view_context.link_to("<i class=\"icon-print\"></i>".html_safe+" Recept ("+recept.created_at.strftime("%Y-%m-%d")+")", recept, :class => 'fancybox.iframe ajax_iframe')
            actions += '</li>'
		  end
		  
		  group_2 += 1
		end
	  end
      
      actions += '<li class="divider"></li>' if group_2 > 0
      
      if can? :order_log, item
        actions += '<li>'+view_context.link_to("<i class=\"icon-time\"></i> Order Logs".html_safe, {controller: "orders", action: "order_log", id: item.id}, title: "Order Logs", target: "_blank")+'</li>'
      end
      if can? :show, item
        actions += '<li>'+view_context.link_to("View", item, title: "Edit Order", class: "fancybox.iframe show_order")+'</li>'
      end
      if can? :update, item
        actions += '<li>'+view_context.link_to("Edit", edit_order_path(item), title: "Edit Order")+'</li>'
      end
      if can? :destroy, item
        actions += '<li>'+view_context.link_to("Delete", item, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'
      end
      if can? :read, item
        actions += '<li>'+view_context.link_to('PDF', download_pdf_orders_path(:id => item.id), :target => "_blank")+'</li>'
      end
      if can? :print_order, item       
        actions += '<li>'+view_context.link_to('Print Order (raw)', print_order_orders_path(:id => item.id), :target => "_blank")+'</li>'
      end
     
      
      actions += '</ul></div></div>'
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def change    
  end
  
  def do_change
    @order.save_draft(current_user)
    respond_to do |format|
      if @order.update(order_params)
        
        if @order.is_purchase || !@order.is_prices_oudated
          @order.confirm_price(current_user)
        else
          @order.confirm_items(current_user)
        end
        
        @order.update_order_details(params[:order_details])       
        
        format.html { redirect_to orders_path, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'change' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
      
  end
  
  def pricing_orders
    @orders = Order.pricing_orders(current_user)
  end
  
  def update_price
  end
  
  def do_update_price
    @order.update_attributes(purchase_manager_id: current_user.id)    
    
    params[:order_details].each do |line|
      od = @order.order_details.find(line[0])
      od.product.update_price(line[1][:product], current_user)
      
      pp = Product.find(od.product.id)
      od.update_attributes(product_price_id: pp.product_price.id, price: pp.product_price.price)
    end
    
    if !params[:product_parts].nil?
      params[:product_parts].each do |line|
        p = Product.find(line[0])
        p.update_price(line[1][:product], current_user)
      end
    end
    
    respond_to do |format|
      if !params[:confirm].nil?
        format.html { redirect_to confirm_price_orders_url(id: @order.id) }
      end
      format.html { redirect_to update_price_orders_url(id: @order.id), notice: 'The prices was successfully updated.' }
      format.json { render action: 'show', status: :created, location: @order }          
    end
  end
  
  def update_info
    @order.order_date = (@order.order_date).strftime("%Y-%m-%d")
    @order.order_deadline = (@order.order_deadline).strftime("%Y-%m-%d")
    #@order.payment_deadline = (@order.payment_deadline).strftime("%Y-%m-%d")
    @order.debt_date = (@order.debt_date).strftime("%Y-%m-%d") if !@order.debt_date.nil?
    @order.debt_days = (@order.debt_date.to_date - @order.order_date.to_date).to_i if !@order.debt_date.nil?
    @order.shipping_date = (@order.shipping_date).strftime("%Y-%m-%d")
  end
  
  def do_update_info
    if params[:page] == "accounting"
      redirect_url = {controller: "accounting", action: "orders"}
    else    
      redirect_url = @order.is_purchase ? purchase_orders_orders_path : orders_path
    end
    
    respond_to do |format|
      if @order.update(update_info_params)
        @order.update_order_details_info(params[:order_details])
        format.html { redirect_to redirect_url, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to update_info_orders_url(id: @order.id), alert: 'Order was unsuccessfully updated. Check the information again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update_tip    
  end
  
  def do_update_tip
    return_url = {controller: "accounting", action: "orders"}
    respond_to do |format|
      if @order.update(update_tip_params)
        @order.update_order_detail_tips(params[:order_details])
        format.html { redirect_to return_url, notice: 'Order tip was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "update_tip" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def order_log
    @logs = @order.order_log
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
      #@order.order_date = @order.order_date.strptime("%m/%d/%Y") if !@order.order_date.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:customer_id, :supplier_id, :agent_id, :shipping_place, :payment_method_id, :payment_deadline, :buyer_name, :buyer_name, :buyer_company, :buyer_address, :buyer_tax_code, :buyer_phone, :buyer_fax, :buyer_email, :tax_id, :order_date,
                                    :order_deadline,
                                    :deposit,
                                    :shipping_date,
                                    :shipping_time,
                                    :warranty_place,
                                    :warranty_cost,
                                    :watermark,
                                    :debt_date,
                                    :customer_po,
                                    :printed_order_number,
                                    :supplier_agent_id,
                                    :discount_amount,
                                    :tip_amount
                                  )
    end
    
    def update_info_params
      params.require(:order).permit(:agent_id, :shipping_place, :payment_method_id, :payment_deadline, :buyer_name, :buyer_name, :buyer_company, :buyer_address, :buyer_tax_code, :buyer_phone, :buyer_fax, :buyer_email, :tax_id, :order_date,
                                    :order_deadline,
                                    :deposit,
                                    :shipping_date,
                                    :shipping_time,
                                    :warranty_place,
                                    :warranty_cost,
                                    :watermark,
                                    :debt_date,
                                    :customer_po,
                                    :printed_order_number,
                                    :supplier_agent_id,
                                    :discount_amount,
                                    :tip_amount
                                  )
    end
    
    def update_tip_params
      params.require(:order).permit(
                                    :tip_amount
                                  )
    end
end
