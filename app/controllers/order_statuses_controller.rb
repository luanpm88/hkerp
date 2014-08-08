class OrderStatusesController < ApplicationController
  before_action :set_order_status, only: [:show, :edit, :update, :destroy]

  # GET /order_statuses
  # GET /order_statuses.json
  def index
    @order_statuses = OrderStatus.all
  end

  # GET /order_statuses/1
  # GET /order_statuses/1.json
  def show
  end

  # GET /order_statuses/new
  def new
    @order_status = OrderStatus.new
  end

  # GET /order_statuses/1/edit
  def edit
  end

  # POST /order_statuses
  # POST /order_statuses.json
  def create
    @order_status = OrderStatus.new(order_status_params)

    respond_to do |format|
      if @order_status.save
        format.html { redirect_to @order_status, notice: 'Order status was successfully created.' }
        format.json { render action: 'show', status: :created, location: @order_status }
      else
        format.html { render action: 'new' }
        format.json { render json: @order_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_statuses/1
  # PATCH/PUT /order_statuses/1.json
  def update
    respond_to do |format|
      if @order_status.update(order_status_params)
        format.html { redirect_to @order_status, notice: 'Order status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_statuses/1
  # DELETE /order_statuses/1.json
  def destroy
    @order_status.destroy
    respond_to do |format|
      format.html { redirect_to order_statuses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_status
      @order_status = OrderStatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_status_params
      params.require(:order_status).permit(:name, :description)
    end
end
