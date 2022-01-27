class ApplicationController < ActionController::Base

  # include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :configure_account_update_params, if: :devise_controller?
  helper_method :check_role
  # before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_path
  end

  def check_role(user)
    user.roles.first.name
  end


  def states
    render json: CS.states(params[:country]).to_json
  end

  def cities
    render json: CS.cities(params[:state]).to_json
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:added_by, :role_name, :first_name, :last_name,
                 :email, :password, :password_confirmation, :about_me,
                 :birth_date, :gender, :schedule_alert_time,
                 :status, :approved, :phone_number,:cancel_percentage,:per_slot_charges,
                 profile_picture_attributes: [:item, :media_type],
                 introduction_video_attributes: [:item, :media_type],
                 address_attributes: [:street_address, :country, :zip, :latitude, :longitude, :house_num, :city, :state])
    end
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(:first_name,:last_name,
               :password,
               :password_confirmation, :about_me,
               :current_password,
               :birth_date, :gender, :schedule_alert_time,
               :status, :approved, :phone_number,:cancel_percentage,:per_slot_charges,
               profile_picture_attributes: [:item, :media_type],
               address_attributes: [:id, :street_address, :country, :zip, :latitude, :longitude, :house_num, :city, :state])
    end
  end
end
