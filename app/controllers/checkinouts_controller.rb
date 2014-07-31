class CheckinoutsController < ApplicationController
  before_action :set_checkinout, only: [:show, :edit, :update, :destroy]

  # GET /checkinouts
  # GET /checkinouts.json
  def index
    @checkinouts = Checkinout.all
  end

  # GET /checkinouts/1
  # GET /checkinouts/1.json
  def show
  end

  # GET /checkinouts/new
  def new
    @checkinout = Checkinout.new
  end

  # GET /checkinouts/1/edit
  def edit
  end

  # POST /checkinouts
  # POST /checkinouts.json
  def create
    @checkinout = Checkinout.new(checkinout_params)

    respond_to do |format|
      if @checkinout.save
        format.html { redirect_to @checkinout, notice: 'Checkinout was successfully created.' }
        format.json { render action: 'show', status: :created, location: @checkinout }
      else
        format.html { render action: 'new' }
        format.json { render json: @checkinout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checkinouts/1
  # PATCH/PUT /checkinouts/1.json
  def update
    respond_to do |format|
      if @checkinout.update(checkinout_params)
        format.html { redirect_to @checkinout, notice: 'Checkinout was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @checkinout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkinouts/1
  # DELETE /checkinouts/1.json
  def destroy
    @checkinout.destroy
    respond_to do |format|
      format.html { redirect_to checkinouts_url }
      format.json { head :no_content }
    end
  end
  
  def import    
    @result = Checkinout.import(params[:file])

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checkinout
      @checkinout = Checkinout.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def checkinout_params
      params.require(:checkinout).permit(:user_id, :check_time)
    end
end
