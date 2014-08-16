class OrdersController < ApplicationController
  load_and_authorize_resource :except => [:print_order]
  
  before_action :set_order, only: [:show, :edit, :update, :destroy, :download_pdf, :print_order]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.order("updated_at DESC").all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @hk = Contact.HK
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
        format.html { redirect_to orders_path, notice: 'Order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @order }
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
          format.html { redirect_to orders_path, notice: 'Order was successfully updated.' }
          format.json { head :no_content }
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
    @hk = Contact.HK
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
    
    @hk = Contact.HK
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
                                    :order_detail_ids => []                                   
                                  )
    end
end
