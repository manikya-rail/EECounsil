class UsersController < ApplicationController
  before_action :find_user, only: [:profile, :update_user_status,
   :update_approval_status, :delete_profile,
   :destroy]
   load_and_authorize_resource

  def index
    @role_name = params[:role_name]
    respond_to do |format|
      format.html
      format.json { render json: UserDatatable.new(params) }
    end
  end

  def profile
  end

  def update_user_status
    status = @user.status ? false : true
    subject = status ? "Activated" : "Deactivated"
    @user.address_validate = true
    @user.update(status: status)
    UserMailer.account_activity_status(@user, subject).deliver_later
    respond_to do |format|
      format.html{ redirect_back fallback_location: users_index_path, notice:"Status is successfully updated"}
      format.js
    end
  end

  def update_approval_status
    @user.address_validate = true
    @user.update(approved: params[:approved])
    UserMailer.account_activity_status(@user, 'Approved').deliver_later
    respond_to do |format|
      format.html{ redirect_back fallback_location: users_index_path}
      format.js
    end
  end

  def delete_profile
    @role_name = check_role(@user)
    if @role_name == 'patient'
      Patient.find(@user.id).schedules.where.not(status: ['canceled','completed']).update(status: "canceled")
    else
      Therapist.find(@user.id).schedules.where.not(status: ['canceled','completed']).update(status: "canceled")
    end
    #UserMailer.account_activity_status(@user, 'Declined').deliver_later
    @user.update(deleted_at: Time.now.utc)
    render json: { role_name: @role_name }
  end

  def delete_therapist
    @user = Therapist.find(params['id'])
    @schedules =  @user.schedules.where.not(status: ['completed','canceled'])
  end

  def check_schedule
    @Schedule_present = Therapist.find(params[:id]).schedules.where.not(status: ['completed','canceled']).any?
    respond_to do |format|
      format.html
      format.json {render json: {Schedule_present: @Schedule_present} }
    end
  end
  private
  def find_user
    @user = User.find(params[:id])
  end
end
