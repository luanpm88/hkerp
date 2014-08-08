class UsersController < ApplicationController
  load_and_authorize_resource
  
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    authorize! :manage, User
    
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    authorize! :manage, User
    
  end

  # GET /users/new
  def new
    authorize! :manage, User
    
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize! :manage, User
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
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
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:password, :password_confirmation, :role_ids => [])
    end
end
