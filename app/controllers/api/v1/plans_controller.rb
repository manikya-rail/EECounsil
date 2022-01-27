module Api
  module V1
    class PlansController < ApplicationController
    	def index
            payment_plans = PaymentPlan.unblocked.order(:amount)
            render json: {payment_plan: ActiveModel::ArraySerializer.new(payment_plans, each_serializer: PaymentPlanSerializer)}
    	end
    	def show
            payment_plan = PaymentPlan.find(params[:id])
    		render json: payment_plan
    	end
    end
	end
end
