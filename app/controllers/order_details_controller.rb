class OrderDetailsController < ApplicationController
  before_action :set_order_detail, only: [:show, :edit, :update, :destroy, :ajax_destroy, :ajax_edit, :ajax_update]

  # GET /order_details
  # GET /order_details.json
  def index
    @order_details = OrderDetail.all
  end

  # GET /order_details/1
  # GET /order_details/1.json
  def show
  end

  # GET /order_details/new
  def new
    @order_detail = OrderDetail.new
  end

  # GET /order_details/1/edit
  def edit
  end

  # POST /order_details
  # POST /order_details.json
  def create
    @order_detail = OrderDetail.new(order_detail_params)

    respond_to do |format|
      if @order_detail.save
        format.html { redirect_to @order_detail, notice: 'Order detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @order_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_details/1
  # PATCH/PUT /order_details/1.json
  def update
    respond_to do |format|
      if @order_detail.update(order_detail_params)
        format.html { redirect_to @order_detail, notice: 'Order detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_details/1
  # DELETE /order_details/1.json
  def destroy
    @order_detail.destroy
    respond_to do |format|
      format.html { redirect_to order_details_url }
      format.json { head :no_content }
    end
  end
  
  # GET /order_details/new
  def ajax_new
    @order_detail = OrderDetail.new
    
    if (!params[:order_id].nil?)
      # @order_detail.order = Order.find_by_id(params[:order_id])
    end
    
    render :layout => nil
  end
  
  # GET /order_details/1/edit
  def ajax_edit
    @order_detail = @order_detail.dup
    @order_detail.order = nil
    
    render :layout => nil
  end
  
  def ajax_create
    @order_detail = OrderDetail.new(order_detail_params)

    respond_to do |format|
      if @order_detail.save
        format.html { render action: 'ajax_show', :layout => nil, :id => @order_detail.id }
        format.json { render action: 'show', status: :created, location: @order_detail }
      else
        format.html { render action: 'ajax_new', :layout => nil }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def ajax_update
    respond_to do |format|
      if @order_detail.update(order_detail_params)
        format.html { render action: 'ajax_show', :layout => nil, :id => @order_detail.id }
        format.json { head :no_content }
      else
        format.html { render action: 'ajax_edit', :layout => nil, :id => @order_detail.id }
        format.json { render json: @order_detail.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /contacts/1
  def ajax_destroy
    @order_detail.destroy
    
    render :nothing => true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_detail
      @order_detail = OrderDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_detail_params
      params.require(:order_detail).permit(:order_id, :product_id, :quantity, :price, :supplier_price, :product_name, :warranty, :unit, :supplier_id, :product_description)
    end
end
