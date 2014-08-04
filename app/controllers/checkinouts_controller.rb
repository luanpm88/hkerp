class CheckinoutsController < ApplicationController
  before_action :set_checkinout, only: [:show, :edit, :update, :destroy]
  
  @@max_time = !Checkinout.where(note: 'imported').order("check_time DESC").empty? ? Checkinout.where(note: 'imported').order("check_time DESC").first.check_time : Time.zone.parse("2010-01-01")

  # GET /checkinouts
  # GET /checkinouts.json
  def index
    Time.zone = "Asia/Bangkok"
    if !params[:year].nil?
      @year = params[:year].to_i
    else
      @year = Time.zone.now.strftime("%Y").to_i
    end
    
    if !params[:month].nil?
      @month = params[:month].to_i
    else
      @month = Time.zone.now.strftime("%m").to_i-1          
    end
    
    if @month == 0
      @month = 12
      @year = @year.to_i - 1
    end
    @state = @@max_time < Time.zone.parse(@year.to_s+"-"+@month.to_s+"-31") ? "Updating" : "Updated"
    @users = User.where.not(id: 1).order("first_name")
    @timezone = Time.zone
  end

  # GET /checkinouts/1
  # GET /checkinouts/1.json
  def show
  end

  # GET /checkinouts/new
  def new
    @checkinout = Checkinout.new
    @checkinout.check_date = params[:check_date]
    @checkinout.check_time = params[:check_date]
    @checkinout.check_time = @checkinout.check_time.change({hour: 7, min: 30})
    @checkinout.user_id = params[:att_no].to_i
  end

  # GET /checkinouts/1/edit
  def edit    
  end

  # POST /checkinouts
  # POST /checkinouts.json
  def create
    @checkinout = Checkinout.new(checkinout_params)
    @checkinout.note = "custom"
    
    respond_to do |format|
      if @checkinout.save
        format.html { redirect_to detail_checkinouts_url(user_id: @checkinout.user.id), notice: 'Checkinout was successfully created.' }
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
    authorize! :create, Checkinout
    
    @checkinout.note = "custom"
    @checkinout.check_time = @checkinout.check_time.change({:hour => params["checkinout"]["check_time(4i)"] , :min => params["checkinout"]["check_time(5i)"]})
    
    respond_to do |format|
      if @checkinout.save
        format.html { redirect_to detail_checkinouts_url(user_id: @checkinout.user.id), notice: 'Checkinout was successfully updated.' }
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
    if !params[:file].nil?
      @result = Checkinout.import(params[:file])
      respond_to do |format|
        format.html { redirect_to checkinouts_url }
        format.json { head :no_content }
      end
    end
  end
  
  def detail
    Time.zone = "Asia/Bangkok"
    
    if !params[:year].nil?
      @year = params[:year].to_i
    else
      @year = Time.zone.now.strftime("%Y").to_i
    end
    
    if !params[:month].nil?
      @month = params[:month].to_i
    else
      @month = Time.zone.now.strftime("%m").to_i-1          
    end
    
    if @month == 0
      @month = 12
      @year = @year.to_i - 1
    end
    
    if !params[:user_id].nil?
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end
    
    authorize! :read_attendances, @user
    
    @checks = Checkinout.get_by_month(@user, @month, @year)
    @work_time = Checkinout.get_work_time_by_month(@user, @month, @year)
    @timezone = Time.zone
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checkinout
      @checkinout = Checkinout.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def checkinout_params
      params.require(:checkinout).permit(:user_id, :check_time, :check_date, :note)
    end
end
