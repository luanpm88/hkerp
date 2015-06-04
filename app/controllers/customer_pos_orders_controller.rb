class CustomerPosOrdersController < ApplicationController
  include ApplicationHelper
  
  load_and_authorize_resource
  
  before_action :set_customer_pos_order, only: [:show, :edit, :update, :destroy]

  # GET /customer_pos_orders
  # GET /customer_pos_orders.json
  def index
    @customer_pos_orders = CustomerPosOrder.all
  end

  # GET /customer_pos_orders/1
  # GET /customer_pos_orders/1.json
  def show
  end

  # GET /customer_pos_orders/new
  def new
    @customer_pos_order = CustomerPosOrder.new
  end

  # GET /customer_pos_orders/1/edit
  def edit
  end

  # POST /customer_pos_orders
  # POST /customer_pos_orders.json
  def create
    @customer_pos_order = CustomerPosOrder.new(customer_pos_order_params)

    respond_to do |format|
      if @customer_pos_order.save
        format.html { redirect_to @customer_pos_order, notice: 'Customer pos order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @customer_pos_order }
      else
        format.html { render action: 'new' }
        format.json { render json: @customer_pos_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_pos_orders/1
  # PATCH/PUT /customer_pos_orders/1.json
  def update
    respond_to do |format|
      if @customer_pos_order.update(customer_pos_order_params)
        format.html { redirect_to @customer_pos_order, notice: 'Customer pos order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @customer_pos_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_pos_orders/1
  # DELETE /customer_pos_orders/1.json
  def destroy
    @customer_pos_order.destroy
    respond_to do |format|
      format.html { redirect_to customer_pos_orders_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_pos_order
      @customer_pos_order = CustomerPosOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_pos_order_params
      params.require(:customer_pos_order).permit(:order_id, :customer_po_id)
    end
end
