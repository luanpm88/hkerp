class CityTypesController < ApplicationController
  load_and_authorize_resource
  before_action :set_city_type, only: [:show, :edit, :update, :destroy]

  # GET /city_types
  # GET /city_types.json
  def index
    @city_types = CityType.all
  end

  # GET /city_types/1
  # GET /city_types/1.json
  def show
  end

  # GET /city_types/new
  def new
    @city_type = CityType.new
  end

  # GET /city_types/1/edit
  def edit
  end

  # POST /city_types
  # POST /city_types.json
  def create
    @city_type = CityType.new(city_type_params)

    respond_to do |format|
      if @city_type.save
        format.html { redirect_to @city_type, notice: 'City type was successfully created.' }
        format.json { render action: 'show', status: :created, location: @city_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @city_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /city_types/1
  # PATCH/PUT /city_types/1.json
  def update
    respond_to do |format|
      if @city_type.update(city_type_params)
        format.html { redirect_to @city_type, notice: 'City type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @city_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /city_types/1
  # DELETE /city_types/1.json
  def destroy
    @city_type.destroy
    respond_to do |format|
      format.html { redirect_to city_types_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_city_type
      @city_type = CityType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def city_type_params
      params.require(:city_type).permit(:name)
    end
end
