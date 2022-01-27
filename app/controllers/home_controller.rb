class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  def index
   role = check_role(current_user)
   @welcome_msg = 'Welcome to Admin Panel'
  end

  private

	def authorize_admin
		if check_role(current_user) != 'admin'
			reset_session
			redirect_to :controller => 'users/sessions', :action => 'new',notice: 'Access Denied'
		end
	end

end
