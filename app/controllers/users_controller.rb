class UsersController < ApplicationController
  include ApplicationHelper
  
  load_and_authorize_resource
  
  before_action :set_user, only: [:avatar, :show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    
    respond_to do |format|
      format.html
      format.json {
        render json: User.full_text_search(params[:q])
      }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if params[:tab_page].present?
      render layout: "content"
    else
      render layout: "none"
    end
  end

  # GET /users/new
  def new
    authorize! :manage, User
    
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize! :manage, User
    
    render layout: "content" if params[:tab_page].present?
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    new_params = user_params
    
    if new_params["password"].empty?      
      new_params.delete("password")
      new_params.delete("password_confirmation")
    end
    
    respond_to do |format|
      if @user.update(new_params)
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize! :manage, User
    
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def backup
    if params[:backup]
      User.backup_system(params)
    end
    
    @files = Dir.glob("backup/*").sort{|a,b| b <=> a}
    
  end
  
  def download_backup
    send_file "backup/"+params[:filename].gsub("backup/",""), :type=>"application/zip"
  end
  
  def delete_backup
    `rm #{"backup/"+params[:filename].gsub("backup/","")}`
    respond_to do |format|
      format.html { redirect_to backup_users_path(tab_page: params[:tab_page]) }
      format.json { head :no_content }
    end
  end
  
  def avatar
    send_file @user.avatar_path(params[:type]), :disposition => 'inline'
  end
  
  def datatable
    result = User.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_users_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def activity_log   
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @user = params[:id].present? ? User.find(params[:id]) : current_user
    
    authorize! :activity_log, @user
    
    @history = @user.activity_log(@from_date, @to_date)
    
    render layout: "content" if params[:tab_page].present?
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:mobile, :email, :first_name, :last_name, :ATT_No, :image, :password, :password_confirmation, :role_ids => [])
    end
end
