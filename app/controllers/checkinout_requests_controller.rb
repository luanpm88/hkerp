class CheckinoutRequestsController < ApplicationController
  load_and_authorize_resource
  
  before_action :set_checkinout_request, only: [:show, :edit, :update, :destroy, :approve]

  # GET /checkinout_requests
  # GET /checkinout_requests.json
  def index
    @checkinout_requests = CheckinoutRequest.where(user_id: current_user.id).order("check_time DESC")
  end

  # GET /checkinout_requests/1
  # GET /checkinout_requests/1.json
  def show
  end

  # GET /checkinout_requests/new
  def new
    Time.zone = "Asia/Bangkok"
    
    @checkinout_request = CheckinoutRequest.new
    @checkinout_request.user = current_user
    @checkinout_request.check_time = params[:check_time].nil? ? Time.zone.now : params[:check_time]
    @checkinout_request.check_time = @checkinout_request.check_time.change({hour: 7, min: 30})
    @checkinout_request.send_request_notification
  end

  # GET /checkinout_requests/1/edit
  def edit
  end

  # POST /checkinout_requests
  # POST /checkinout_requests.json
  def create
    @checkinout_request = CheckinoutRequest.new(checkinout_request_params)
    @checkinout_request.user = current_user
    @checkinout_request.status = 0

    respond_to do |format|
      if @checkinout_request.save
        format.html { redirect_to checkinout_requests_url, notice: 'Checkinout request was successfully created.' }
        format.json { render action: 'show', status: :created, location: @checkinout_request }
      else
        format.html { render action: 'new' }
        format.json { render json: @checkinout_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checkinout_requests/1
  # PATCH/PUT /checkinout_requests/1.json
  def update
    respond_to do |format|
      if @checkinout_request.update(checkinout_request_params)
        format.html { redirect_to checkinout_requests_url, notice: 'Checkinout request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @checkinout_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkinout_requests/1
  # DELETE /checkinout_requests/1.json
  def destroy
    @checkinout_request.destroy
    respond_to do |format|
      format.html { redirect_to checkinout_requests_url }
      format.json { head :no_content }
    end
  end
  
  def approve
    @checkinout_request.status = 1
    @checkinout_request.manager = current_user
    @checkinout_request.approve_request
    

    respond_to do |format|
      if @checkinout_request.save
        format.html { redirect_to checkinout_requests_url, notice: 'Checkinout request was successfully created.' }
        format.json { render action: 'show', status: :created, location: @checkinout_request }
      else
        format.html { redirect_to checkinout_requests_url, alert: 'Checkinout request was unsuccessfully created.' }
        format.json { render json: @checkinout_request.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checkinout_request
      @checkinout_request = CheckinoutRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def checkinout_request_params
      params.require(:checkinout_request).permit(:check_time, :content)
    end
end
