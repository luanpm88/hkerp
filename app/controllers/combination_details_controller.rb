class CombinationDetailsController < ApplicationController
  load_and_authorize_resource
  before_action :set_combination_detail, only: [:show, :edit, :update, :destroy]

  # GET /combination_details
  # GET /combination_details.json
  def index
    @combination_details = CombinationDetail.all
  end

  # GET /combination_details/1
  # GET /combination_details/1.json
  def show
  end

  # GET /combination_details/new
  def new
    @combination_detail = CombinationDetail.new
  end

  # GET /combination_details/1/edit
  def edit
  end

  # POST /combination_details
  # POST /combination_details.json
  def create
    @combination_detail = CombinationDetail.new(combination_detail_params)

    respond_to do |format|
      if @combination_detail.save
        format.html { redirect_to @combination_detail, notice: 'Combination detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @combination_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @combination_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /combination_details/1
  # PATCH/PUT /combination_details/1.json
  def update
    respond_to do |format|
      if @combination_detail.update(combination_detail_params)
        format.html { redirect_to @combination_detail, notice: 'Combination detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @combination_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /combination_details/1
  # DELETE /combination_details/1.json
  def destroy
    @combination_detail.destroy
    respond_to do |format|
      format.html { redirect_to combination_details_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_combination_detail
      @combination_detail = CombinationDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def combination_detail_params
      params.require(:combination_detail).permit(:combination_id, :product_id, :stock_before, :quantity, :stock_after)
    end
end
