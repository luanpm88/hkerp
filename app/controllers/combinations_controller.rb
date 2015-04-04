class CombinationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_combination, only: [:show, :edit, :update, :destroy]

  # GET /combinations
  # GET /combinations.json
  def index
    @combinations = Combination.all
  end

  # GET /combinations/1
  # GET /combinations/1.json
  def show
  end

  # GET /combinations/new
  def new
    @combination = Combination.new(product_id: params[:product_id])
    @product = Product.find(params[:product_id])
  end

  # GET /combinations/1/edit
  def edit
  end

  # POST /combinations
  # POST /combinations.json
  def create
    @combination = Combination.new(combination_params)
    @product = Product.find(@combination.product_id)
    
    @combination.user = current_user
    
    @combination.stock_before = @product.stock
    serials = []
    @product.parts.each do |p|
      num = @product.product_parts.where(part_id: p.id).first.quantity*@combination.quantity
      serial_numbers = Product.extract_serial_numbers(params["serial_numbers_"+p.id.to_s])
      
      com_detail = @combination.combination_details.new(product_id: p.id,stock_before: p.stock,quantity: num,serial_numbers: serial_numbers.join("\r\n"))
      
      serials << p.id.to_s+"---------\r\n"+serial_numbers.join("\r\n")
    end
    @combination.serial_numbers = serials.join("\r\n")

    
    respond_to do |format|
      if @combination.save
        @combination.proccess
        
        format.html { redirect_to new_combination_path(product_id: @combination.product_id), notice: 'Combination was successfully created.' }
        format.json { render action: 'show', status: :created, location: @combination }
      else
        format.html { render action: 'new' }
        format.json { render json: @combination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /combinations/1
  # PATCH/PUT /combinations/1.json
  def update
    respond_to do |format|
      if @combination.update(combination_params)
        format.html { redirect_to @combination, notice: 'Combination was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @combination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /combinations/1
  # DELETE /combinations/1.json
  def destroy
    @combination.destroy
    respond_to do |format|
      format.html { redirect_to combinations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_combination
      @combination = Combination.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def combination_params
      params.require(:combination).permit(:product_id, :quantity)
    end
end
