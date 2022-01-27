module Api
  module V1
    class TherapistPackagesController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!


      def index
      	render json: current_user.subscribed_plan
      end

      def cancel_subscription
      	plan = PaymentPlan.where(id: params[:id])
      	if plan.present? && (plan.first.stripe_plan_id.to_s == current_user.stripe_plan_id.to_s)
      		StripeChargesServices.new({},current_user).cancel_subscription
      	end
      end
  	end
	end
end
