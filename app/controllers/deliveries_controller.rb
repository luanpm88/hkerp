class DeliveriesController < ApplicationController
  before_action :set_delivery, only: [:show, :edit, :update, :destroy, :download_pdf]

  # GET /deliveries
  # GET /deliveries.json
  def index
    if params[:purchase]
      @orders = Order.get_purchase_orders_with_delivery
    else
      @orders = Order.get_sales_orders_with_delivery
    end
    
    
  end
  
  # GET /deliveries/1
  # GET /deliveries/1.json
  def deliver
    @order = Order.find(params[:id])
    @delivery = Delivery.new
  end

  # GET /deliveries/1
  # GET /deliveries/1.json
  def show
    @order = @delivery.order
    
    @hk = @order.supplier
    render :layout => nil
  end
  
  def download_pdf
    @order = @delivery.order
    
    @hk = @order.supplier
    render  :pdf => "quotation_"+@order.quotation_code,
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
  end

  # GET /deliveries/1/edit
  def edit
  end

  # POST /deliveries
  # POST /deliveries.json
  def create
    @order = Order.find(delivery_params[:order_id])
    @delivery = Delivery.new(delivery_params)
    
    # Update sales delivery details
    if !params[:delivery_lines].nil?
      params[:delivery_lines].each do |item|
        if item[1][:quantity].to_i > 0
          detail = DeliveryDetail.new(item[1])
          @delivery.delivery_details << detail
        end
      end
    end
    
    list_path = @delivery.order.is_purchase ? deliveries_url(purchase: true) : deliveries_url
    
    respond_to do |format|
      if @delivery.valid?
        @delivery.update_stock
        format.html { redirect_to list_path, notice: 'Sales delivery was successfully created.' }
        format.json { render action: 'show', status: :created, location: @delivery }
      else
        format.html { render action: 'deliver' }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deliveries/1
  # PATCH/PUT /deliveries/1.json
  def update
    respond_to do |format|
      if @delivery.update(delivery_params)
        format.html { redirect_to @delivery, notice: 'Delivery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery
      @delivery = Delivery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_params
      params.require(:delivery).permit(:order_id, :user_id)
    end
end
