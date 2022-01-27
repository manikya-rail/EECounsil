module Api
  module V1
    class ConsentFormsController < ApplicationController
      def index
        consent_forms = ConsentForm.all
        render json: consent_forms
      end
      def show
        consent_form = ConsentForm.find(params[:id])
        render json: consent_form
      end

      def fetch_client_consent_form
        params_hash = {therapist_id: params[:therapist_id], patient_id: params[:patient_id]}
        if params[:consent_form_id]
          params_hash.merge!(consent_form_id: params[:consent_form_id]) if params[:consent_form_id]
          consent_forms = ClientConsentForm.where(params_hash)
        else
          consent_form_ids = ClientConsentForm.where(params_hash).pluck(:consent_form_id)
          consent_forms = ConsentForm.where(id: consent_form_ids)
        end
        render json: consent_forms
      end
    end
  end
end
