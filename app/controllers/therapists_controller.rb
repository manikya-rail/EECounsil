class TherapistsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, only: [:create]

  def index
    respond_to do |format|
      format.html
      format.json { render json: TherapistDatatable.new(params) }
    end
  end

  def create
    @payout = StripePayoutServices.new(@therapist,params['amount'],current_user).pay
    if @payout['error'].present?
      flash.now[:alert] =  @payout['error']
      render 'index'
    else
      redirect_to therapists_path, notice: "Paid Successfully!"
    end
  end

  private

  def find_user
    @therapist = Therapist.find(params['user_id']);
  end

end
