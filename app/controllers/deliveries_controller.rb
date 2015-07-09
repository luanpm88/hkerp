class DeliveriesController < ApplicationController
  load_and_authorize_resource :except => [:deliver, :create]
  before_action :set_delivery, only: [:trash, :show, :edit, :update, :destroy, :download_pdf]

  # GET /deliveries
  # GET /deliveries.json
  def index
    #if params[:purchase] == true
      #@orders = Order.delivery_purchase_orders
    #else
    #  @orders = Order.delivery_sales_orders
    #end
    
    
  end
  
  # GET /deliveries/1
  # GET /deliveries/1.json
  def deliver
    @order = Order.find(params[:order_id])
    
    authorize! :deliver, @order
    
    @delivery = Delivery.new
    @delivery.delivery_date = (Time.now).strftime("%Y-%m-%d")
    
    
  end

  # GET /deliveries/1
  # GET /deliveries/1.json
  def show
    @order = @delivery.order
    
    @hk = @order.supplier
    render :layout => "content"
  end
  
  def download_pdf
    @order = @delivery.order
    
    filename = @order.is_purchase ? "purchase_delivery" : "sales_delivery"
    
    @hk = @order.supplier
    render  :pdf => filename+"_"+@order.quotation_code+"-"+@delivery.id.to_s,
            :template => 'deliveries/show.pdf.erb',
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

  # GET /deliveries/new
  def new
    @delivery = Delivery.new
    @delivery.delivery_date = (Time.now).strftime("%Y-%m-%d")
  end

  # GET /deliveries/1/edit
  def edit
    @order = Order.find(@delivery.order_id)
  end

  # POST /deliveries
  # POST /deliveries.json
  def create
    @order = Order.find(delivery_params[:order_id])
    
    authorize! :deliver, @order
    
    @delivery = Delivery.new(delivery_params)
    @delivery.creator = current_user
    
    # Update sales delivery details
    if !params[:delivery_lines].nil?
      params[:delivery_lines].each do |item|
        if item[1][:quantity].to_i != 0
          detail = DeliveryDetail.new(item[1].permit(:order_detail_id, :product_id, :serial_numbers, :delivery_id, :quantity))
          @delivery.delivery_details << detail
        end
      end
    end
    
    #p @delivery.valid?
    #p @delivery.save
    
    #render nothing: true
    
    
    @list_path = @delivery.order.is_purchase ? deliveries_url(purchase: true) : deliveries_url
    
    respond_to do |format|
      if @delivery.valid?
        @delivery.update_stock
        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @delivery.id, tab_page: 1, export_ticket: (@delivery.is_return ? true : nil)} : @delivery, notice: 'Sales delivery was successfully created.' }
        format.json { render action: 'show', status: :created, location: @delivery }
      else
        format.html { render action: 'deliver', tab_page: params[:tab_page] }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deliveries/1
  # PATCH/PUT /deliveries/1.json
  def update
    respond_to do |format|
      if @delivery.update(delivery_params)
        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @delivery.id, tab_page:1} : @delivery, notice: 'Delivery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deliveries/1
  # DELETE /deliveries/1.json
  def destroy
    @delivery.destroy
    respond_to do |format|
      format.html { redirect_to deliveries_url }
      format.json { head :no_content }
    end
  end
  
  def trash
    list_path = @delivery.order.is_purchase ? deliveries_url(purchase: true) : deliveries_url
    
    respond_to do |format|
      if @delivery.trash
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : list_path, notice: 'Delivery was successfully trashed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @delivery.id, tab_page:1} : list_path, alert: 'Delivery was unsuccessfully trashed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery
      @delivery = Delivery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_params
      params.require(:delivery).permit(:delivery_date, :is_return, :delivery_person_id, :order_id, :user_id)
    end
end
