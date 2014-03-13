class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :download_pdf]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.order("created_at DESC").all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @hk = Contact.HK
    render :layout => nil
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.order_date = Time.now
    @order.order_deadline = Time.now + 7.days
    @order.payment_deadline = Time.now + 3.days
  end

  # GET /orders/1/edit
  def edit
    authorize! :manage, @order
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @order.salesperson = current_user
    @order.create_quotation_code
    
    respond_to do |format|
      if @order.save
        #save order quotation code
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
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to orders_path, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
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
                                    :order_detail_ids => []                                   
                                  )
    end
end
