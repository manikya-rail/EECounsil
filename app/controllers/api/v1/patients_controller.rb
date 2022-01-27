module Api
  module V1
    class PatientsController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!, except: :show
      before_action :find_patient

      def therapist_default_rate
        therapist_rate_for_patient = TherapistRatePerClient.where(therapist_id: params[:therapist_id], patient_id: @patient.id).first
        render json: {default_rate: therapist_rate_for_patient.default_rate}
      end

      private

      def find_patient
        @patient = Patient.find(params[:id])
      end

    end
  end
end
