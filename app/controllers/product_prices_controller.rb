class ProductPricesController < ApplicationController
  before_action :set_product_price, only: [:show, :edit, :update, :destroy]

  # GET /product_prices
  # GET /product_prices.json
  def index
    @product_prices = ProductPrice.all
  end

  # GET /product_prices/1
  # GET /product_prices/1.json
  def show
  end

  # GET /product_prices/new
  def new
    @product_price = ProductPrice.new
  end

  # GET /product_prices/1/edit
  def edit
  end

  # POST /product_prices
  # POST /product_prices.json
  def create
    @product_price = ProductPrice.new(product_price_params)

    respond_to do |format|
      if @product_price.save
        format.html { redirect_to @product_price, notice: 'Product price was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product_price }
      else
        format.html { render action: 'new' }
        format.json { render json: @product_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_prices/1
  # PATCH/PUT /product_prices/1.json
  def update
    respond_to do |format|
      if @product_price.update(product_price_params)
        format.html { redirect_to @product_price, notice: 'Product price was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_prices/1
  # DELETE /product_prices/1.json
  def destroy
    @product_price.destroy
    respond_to do |format|
      format.html { redirect_to product_prices_url }
      format.json { head :no_content }
    end
  end  


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_price
      @product_price = ProductPrice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_price_params
      params.require(:product_price).permit(:product_id, :price, :supplier_price, :supplier_id)
    end
end
