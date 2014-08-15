class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  
  before_action :authenticate_user!
  
  layout :layout_by_resource
    
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end 
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Access denied."
    begin
      redirect_to :back
    rescue
      redirect_to root_url
    end
  end
  
  def layout_by_resource
    if devise_controller? && resource_name == :user && action_name == 'new'
      "login"
    else
      "application"
    end
  end
  
  protected
  
  def configure_devise_permitted_parameters
    registration_params = [:first_name, :last_name, :email, :password, :password_confirmation, :phone_ext, :mobile, :image]

    if params[:action] == 'update'
      devise_parameter_sanitizer.for(:account_update) { 
        |u| u.permit(registration_params << :current_password)
      }
    elsif params[:action] == 'create'
      devise_parameter_sanitizer.for(:sign_up) { 
        |u| u.permit(registration_params) 
      }
    end
  end
    
end
