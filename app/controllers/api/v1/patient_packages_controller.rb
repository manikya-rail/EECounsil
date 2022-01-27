module Api
  module V1
    class PatientPackagesController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!
      before_action :find_patient, only: [:index]

      def index
        if params[:package_id].present? && params[:package_id] != "null"
          @package_plans = PatientPackage.find_by(patient_id: @patient.id,package_id: params[:package_id])
          render json: @package_plans.patient_package_plans
        else
          @patient_packages = @patient.patient_packages.pluck(:package_id)
          @packages = Package.all.as_json(@patient_packages)
          render json: @packages
        end
      end

      def new
      end

      def create
        @response_data = StripeChargesServices.new(payment_params,current_user).call
        render json: @response_data
      end

      private

      def payment_params
        params.permit(:stripeEmail, :stripeToken, :package_id)
      end

      def find_patient
        @patient = Patient.find(current_user.id)
      end
    end
  end
end
