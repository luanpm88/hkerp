class DeliveryDetailsController < ApplicationController
  before_action :set_delivery_detail, only: [:show, :edit, :update, :destroy]

  # GET /delivery_details
  # GET /delivery_details.json
  def index
    @delivery_details = DeliveryDetail.all
  end

  # GET /delivery_details/1
  # GET /delivery_details/1.json
  def show
  end

  # GET /delivery_details/new
  def new
    @delivery_detail = DeliveryDetail.new
  end

  # GET /delivery_details/1/edit
  def edit
  end

  # POST /delivery_details
  # POST /delivery_details.json
  def create
    @delivery_detail = DeliveryDetail.new(delivery_detail_params)

    respond_to do |format|
      if @delivery_detail.save
        format.html { redirect_to @delivery_detail, notice: 'Delivery detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @delivery_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @delivery_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delivery_details/1
  # PATCH/PUT /delivery_details/1.json
  def update
    respond_to do |format|
      if @delivery_detail.update(delivery_detail_params)
        format.html { redirect_to @delivery_detail, notice: 'Delivery detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @delivery_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_details/1
  # DELETE /delivery_details/1.json
  def destroy
    @delivery_detail.destroy
    respond_to do |format|
      format.html { redirect_to delivery_details_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_detail
      @delivery_detail = DeliveryDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_detail_params
      params.require(:delivery_detail).permit(:delivery_id, :order_detail_id, :quantity)
    end
end
