# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def new
    if flash[:alert] == unauthenticated_message
      flash.delete(:alert) unless requested_protected_page?
    end
    super
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected
  private

  def requested_protected_page?
    session[:user_return_to] != root_path
  end

  def unauthenticated_message
    I18n.t('devise.failure.unauthenticated')
  end
  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
