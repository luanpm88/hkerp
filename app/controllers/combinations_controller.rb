class CombinationsController < ApplicationController
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
    @combination = Combination.new
  end

  # GET /combinations/1/edit
  def edit
  end

  # POST /combinations
  # POST /combinations.json
  def create
    @combination = Combination.new(combination_params)

    respond_to do |format|
      if @combination.save
        format.html { redirect_to @combination, notice: 'Combination was successfully created.' }
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
