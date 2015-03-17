class SalesDeliveryDetailsController < ApplicationController
  before_action :set_sales_delivery_detail, only: [:show, :edit, :update, :destroy]

  # GET /sales_delivery_details
  # GET /sales_delivery_details.json
  def index
    @sales_delivery_details = SalesDeliveryDetail.all
  end

  # GET /sales_delivery_details/1
  # GET /sales_delivery_details/1.json
  def show
  end

  # GET /sales_delivery_details/new
  def new
    @sales_delivery_detail = SalesDeliveryDetail.new
  end

  # GET /sales_delivery_details/1/edit
  def edit
  end

  # POST /sales_delivery_details
  # POST /sales_delivery_details.json
  def create
    @sales_delivery_detail = SalesDeliveryDetail.new(sales_delivery_detail_params)

    respond_to do |format|
      if @sales_delivery_detail.save
        format.html { redirect_to @sales_delivery_detail, notice: 'Sales delivery detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @sales_delivery_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @sales_delivery_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales_delivery_details/1
  # PATCH/PUT /sales_delivery_details/1.json
  def update
    respond_to do |format|
      if @sales_delivery_detail.update(sales_delivery_detail_params)
        format.html { redirect_to @sales_delivery_detail, notice: 'Sales delivery detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sales_delivery_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_delivery_details/1
  # DELETE /sales_delivery_details/1.json
  def destroy
    @sales_delivery_detail.destroy
    respond_to do |format|
      format.html { redirect_to sales_delivery_details_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_delivery_detail
      @sales_delivery_detail = SalesDeliveryDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sales_delivery_detail_params
      params.require(:sales_delivery_detail).permit(:sales_delivery_id, :order_detail_id, :quantity)
    end
end
