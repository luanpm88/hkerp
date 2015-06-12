class RegistrationsController < Devise::RegistrationsController

  protected

    def after_update_path_for(resource)
      edit_user_registration_path(tab_page: 1)
    end
end