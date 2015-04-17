class ProductStockUpdatesController < ApplicationController
  load_and_authorize_resource
  before_action :set_product_stock_update, only: [:show, :edit, :update, :destroy]

  # GET /product_stock_updates
  # GET /product_stock_updates.json
  def index
    @product_stock_updates = ProductStockUpdate.all
  end

  # GET /product_stock_updates/1
  # GET /product_stock_updates/1.json
  def show
  end

  # GET /product_stock_updates/new
  def new
    @product_stock_update = ProductStockUpdate.new(product_id: params[:product_id])
    @product = Product.find(params[:product_id])
  end

  # GET /product_stock_updates/1/edit
  def edit
  end

  # POST /product_stock_updates
  # POST /product_stock_updates.json
  def create
    @product_stock_update = ProductStockUpdate.new(product_stock_update_params)
    @product = Product.find(@product_stock_update.product_id)
    
    @product_stock_update.user = current_user
    
    respond_to do |format|
      if @product_stock_update.save
        format.html { redirect_to products_url, notice: 'Product stock update was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product_stock_update }
      else
        format.html { render action: 'new' }
        format.json { render json: @product_stock_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_stock_updates/1
  # PATCH/PUT /product_stock_updates/1.json
  def update
    respond_to do |format|
      if @product_stock_update.update(product_stock_update_params)
        format.html { redirect_to @product_stock_update, notice: 'Product stock update was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product_stock_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_stock_updates/1
  # DELETE /product_stock_updates/1.json
  def destroy
    @product_stock_update.destroy
    respond_to do |format|
      format.html { redirect_to product_stock_updates_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_stock_update
      @product_stock_update = ProductStockUpdate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_stock_update_params
      params.require(:product_stock_update).permit(:note, :is_import, :product_id, :quantity, :serial_numbers)
    end
end
