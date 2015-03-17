class SalesDeliveriesController < ApplicationController
  before_action :set_sales_delivery, only: [:show, :edit, :update, :destroy, :download_pdf]

  # GET /sales_deliveries
  # GET /sales_deliveries.json
  def index
    @orders = Order.get_sales_orders_with_delivery
  end
  
  # GET /sales_deliveries/1
  # GET /sales_deliveries/1.json
  def deliver
    @order = Order.find(params[:id])
    @sales_delivery = SalesDelivery.new
  end

  # GET /sales_deliveries/1
  # GET /sales_deliveries/1.json
  def show
    @order = @sales_delivery.order
    
    @hk = @order.supplier
    render :layout => nil
  end
  
  def download_pdf
    @order = @sales_delivery.order
    
    @hk = @order.supplier
    render  :pdf => "quotation_"+@order.quotation_code,
            :template => 'sales_deliveries/show.pdf.erb',
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

  # GET /sales_deliveries/new
  def new
    @sales_delivery = SalesDelivery.new
  end

  # GET /sales_deliveries/1/edit
  def edit
  end

  # POST /sales_deliveries
  # POST /sales_deliveries.json
  def create
    @sales_delivery = SalesDelivery.new(sales_delivery_params)
    
    # Update sales delivery details
    if !params[:sales_delivery_lines].nil?
      params[:sales_delivery_lines].each do |item|
        @sales_delivery.sales_delivery_details.new(item[1]) if item[1][:quantity].to_i > 0
      end
    end
    
    respond_to do |format|
      if @sales_delivery.update_stock
        format.html { redirect_to sales_deliveries_url, notice: 'Sales delivery was successfully created.' }
        format.json { render action: 'show', status: :created, location: @sales_delivery }
      else
        format.html { redirect_to  sales_deliveries_url, alert: 'Sales delivery was unsuccessfully created.' }
        format.json { render json: @sales_delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales_deliveries/1
  # PATCH/PUT /sales_deliveries/1.json
  def update
    respond_to do |format|
      if @sales_delivery.update(sales_delivery_params)
        format.html { redirect_to @sales_delivery, notice: 'Sales delivery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sales_delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_deliveries/1
  # DELETE /sales_deliveries/1.json
  def destroy
    @sales_delivery.destroy
    respond_to do |format|
      format.html { redirect_to sales_deliveries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_delivery
      @sales_delivery = SalesDelivery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sales_delivery_params
      params.require(:sales_delivery).permit(:order_id)
    end
end
