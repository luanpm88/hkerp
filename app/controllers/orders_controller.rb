class OrdersController < ApplicationController
  load_and_authorize_resource :except => [:datatable]
  
  before_action :set_order, only: [:finish_order, :update_info, :do_update_info, :confirm_price, :do_update_price, :update_price, :do_change, :change, :pdf_preview, :show, :edit, :update, :destroy, :download_pdf, :print_order, :confirm_order]

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
      @order.payment_deadline = (Time.now + 3.days).strftime("%Y-%m-%d")
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
      @order.payment_deadline = (@order.payment_deadline).strftime("%Y-%m-%d")
      @order.debt_date = (@order.debt_date).strftime("%Y-%m-%d") if !@order.debt_date.nil?
      @order.debt_days = (@order.debt_date.to_date - @order.order_date.to_date).to_i if !@order.debt_date.nil?
      @order.shipping_date = (@order.shipping_date).strftime("%Y-%m-%d")
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @order.salesperson = current_user
    @order.create_quotation_code
    
    order_details_params = params[:order_details]
    if !order_details_params.nil?
        order_details_params.each do |line|
        od = OrderDetail.new(line[1])      
        @order.order_details << od
      end
    end
    
    p @order.order_details    
    
    respond_to do |format|
      if @order.save
        @order.set_status('new')
        if !@order.is_purchase
          format.html { redirect_to orders_path, notice: 'Order was successfully created.' }
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
    @order.save_draft
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
      if @order.confirm_order        
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
      if @order.confirm_items        
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
      if @order.confirm_price        
        format.html { redirect_to pricing_orders_orders_url, notice: 'Order Prices was successfully confimed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to update_price_orders_url(id: @order.id), alert: 'Order Price was unsuccessfully confimed. Check the prices again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def finish_order
    return_url = {controller: "accounting", action: "orders"}
    respond_to do |format|
      if @order.finish_order        
        format.html { redirect_to return_url, notice: 'Order was successfully finished.' }
        format.json { head :no_content }
      else
        format.html { redirect_to return_url, alert: 'Order was unsuccessfully finished. Check the order again.' }
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
      
      
      if can? :update_info, item
        actions += '<li>'+view_context.link_to("Update Info", update_info_orders_path(:id => item.id))+'</li>'
      end
      if can? :confirm_items, item
        actions += '<li>'+view_context.link_to("Confirm Items", confirm_items_orders_path(:id => item.id), data: { confirm: 'Are you sure?' })+'</li>'
      end
      if can? :confirm_order, item
        actions += '<li>'+view_context.link_to("Confirm Order", confirm_order_orders_path(:id => item.id), data: { confirm: 'Are you sure?' })+'</li>'
      end
      if can? :change, item
        actions += '<li>'+view_context.link_to("Change Items", change_orders_path(:id => item.id))+'</li>'
      end
      if can? :update, item
        actions += '<li>'+view_context.link_to("Edit", edit_order_path(item), title: "Edit Order")+'</li>'
      end   
      actions += '<li class="divider"></li>'
      if can? :show, item
        actions += '<li>'+view_context.link_to("View", item, title: "Edit Order", class: "fancybox.iframe show_order")+'</li>'
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
      
      result[:result]["data"][index][7] = actions
    end
    
    render json: result[:result]
  end
  
  def change    
  end
  
  def do_change
    @order.save_draft
    respond_to do |format|
      if @order.update(order_params)
        
        if @order.is_purchase || !@order.is_prices_oudated
          @order.confirm_price
        else
          @order.confirm_items
        end
        
        @order.update_order_details(params[:order_details])       
        
        format.html { redirect_to orders_path, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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
      od.product.update_price(line[1][:product])
      od.update_attributes(price: od.product.product_price.price)
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
    @order.payment_deadline = (@order.payment_deadline).strftime("%Y-%m-%d")
    @order.debt_date = (@order.debt_date).strftime("%Y-%m-%d") if !@order.debt_date.nil?
    @order.debt_days = (@order.debt_date.to_date - @order.order_date.to_date).to_i if !@order.debt_date.nil?
    @order.shipping_date = (@order.shipping_date).strftime("%Y-%m-%d")
  end
  
  def do_update_info
    if params[:accounting]
      redirect_url = {controller: "accounting", action: "orders"}
    else    
      redirect_url = orders_url
    end
    
    respond_to do |format|
      if @order.update(update_info_params)
        format.html { redirect_to redirect_url, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to update_info_orders_url(id: @order.id), alert: 'Order was unsuccessfully updated. Check the information again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
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
                                    :printed_order_number
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
                                    :printed_order_number
                                  )
    end
end
