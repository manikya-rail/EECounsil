class Api::V1::ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery

  def check_role(user)
    user.roles.first.name
  end
end
