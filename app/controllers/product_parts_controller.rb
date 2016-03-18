class ProductPartsController < ApplicationController
  before_action :set_product_part, only: [:show, :edit, :update, :destroy]

  # GET /product_parts
  # GET /product_parts.json
  def index
    @product_parts = ProductPart.all
  end

  # GET /product_parts/1
  # GET /product_parts/1.json
  def show
  end

  # GET /product_parts/new
  def new
    @product_part = ProductPart.new
  end

  # GET /product_parts/1/edit
  def edit
  end

  # POST /product_parts
  # POST /product_parts.json
  def create
    @product_part = ProductPart.new(product_part_params)

    respond_to do |format|
      if @product_part.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @product_part, notice: 'Product part was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product_part }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @product_part.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_parts/1
  # PATCH/PUT /product_parts/1.json
  def update
    respond_to do |format|
      if @product_part.update(product_part_params)
        format.html { redirect_to @product_part, notice: 'Product part was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product_part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_parts/1
  # DELETE /product_parts/1.json
  def destroy
    @product_part.destroy
    respond_to do |format|
      format.html { redirect_to product_parts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_part
      @product_part = ProductPart.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_part_params
      params.require(:product_part).permit(:product_id, :part_id, :quantity)
    end
end
