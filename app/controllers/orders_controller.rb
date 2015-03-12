class OrdersController < ApplicationController
  load_and_authorize_resource :except => [:datatable]
  
  before_action :set_order, only: [:show, :edit, :update, :destroy, :download_pdf, :print_order, :confirm_order]

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
    if !params[:old_id].nil?
      @order = Order.find_by_id(params[:old_id]).new_order_history
    else    
      @order = Order.new
      @order.order_date = (Time.now).strftime("%Y-%m-%d")
      @order.order_deadline = (Time.now + 7.days).strftime("%Y-%m-%d")
      @order.payment_deadline = (Time.now + 3.days).strftime("%Y-%m-%d")
      @order.shipping_date = (Time.now).strftime("%Y-%m-%d")
      @order.warranty_place = "Tận nơi"
      @order.warranty_cost = "0"
      if !params[:purchase].nil?
        @order.customer = Contact.HK
      else
        @order.supplier = Contact.HK
      end
      
    end
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @order.salesperson = current_user
    @order.create_quotation_code
    
    respond_to do |format|
      if @order.save
        @order.set_status('quotation')
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
    
    if !params[:dup].nil?
      new_params = order_params
      new_params[:order_detail_ids] = []
      @dup_order = Order.new(new_params)
      @dup_order.salesperson = current_user
      @dup_order.create_quotation_code
      
      @dup_order.older = @order
      
      params[:order][:order_detail_ids].each do |id|
        if @order.order_details.map(&:id).include?(id.to_i)
          od = @order.order_details.find_by_id(id.to_i).dup
          od.save
          @dup_order.order_details << od
        else
          @dup_order.order_details << OrderDetail.find_by_id(id.to_i)
        end
      end
      respond_to do |format|
        if @dup_order.save
          @dup_order.set_status('quotation')
          if !@order.is_purchase
            format.html { redirect_to orders_path, notice: 'Order was successfully updated.' }
            format.json { render action: 'show', status: :created, location: @order }
          else
            format.html { redirect_to purchase_orders_orders_path, notice: 'Order was successfully updated.' }
            format.json { render action: 'show', status: :created, location: @order }
          end
        else
          @order = @dup_order
          format.html { render action: 'edit' }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @order.update(order_params)
          if !params[:confirm].nil?
            @order.confirm_order
          end
          format.html { redirect_to orders_path, notice: 'Order was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
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
    render  :pdf => "quotation_"+@order.quotation_code,
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
  end
  
  def purchase_orders
    #Find Customer orders
    @orders = Order.purchase_orders
    
  end
  
  def confirm_order
    @order.confirm_order
    
    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    authorize! :view_list, Order
    
    result = Order.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      
      
      actions = '<div class="text-right"><div class="btn-group" style="height: 26px;">
                    <button class="btn btn-mini btn-white btn-demo-space">More</button>
                    <button class="btn btn-mini btn-white dropdown-toggle btn-demo-space" data-toggle="dropdown"> <span class="caret"></span> </button>'
      actions += '<ul class="dropdown-menu">'
      
      if can? :confirm_order, item
        actions += '<li>'+view_context.link_to("Confirm", confirm_order_orders_path(:id => item.id), data: { confirm: 'Are you sure?' })+'</li>'
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
      
      result[:result]["data"][index][7] = actions
    end
    
    render json: result[:result]
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
                                    :order_detail_ids => []                                   
                                  )
    end
end
