module Api
  module V1
  	class RegistrationsController < DeviseTokenAuth::RegistrationsController
      before_action :set_user_by_token, only: [:destroy, :update]
      before_action :find_user, only: [:profile, :edit_profile, :update_profile]

      def new
        render json: { countries: CS.countries, states: CS.states(:us) }
      end

      def create
        build_resource(sign_up_params)
        if resource.save
          response_code = resource.register_therapist_with_zoom if resource.role_name == "therapist"
          create_client_consent_forms if resource.role_name == 'patient'
          if params[:promo_code].present? && resource.role_name == "therapist"
            promo_code = PromoCode.find_by_code(params[:promo_code])
            Promo.create(therapist_id: resource.id, promo_code_id: promo_code.id, active: true) if promo_code.present?
          end
          yield resource if block_given?
          if resource.persisted?
            if resource.active_for_authentication?
              set_flash_message! :notice, :signed_up
              if (resource.role_name == "patient" && !resource.added_by.present?) || resource.role_name == "therapist"
                sign_up(resource_name, resource)
              end
                render json: resource
            else
              render json: resource
            end
          else
            clean_up_passwords resource
            #set_minimum_password_length
            render_create_error
          end
        else
          render json: { errors: resource.errors }
        end
      end

      def update
        if @resource
          @resource.user_payers.delete_all if @resource.user_payers
          @resource.user_insurance_detail.delete if @resource.user_insurance_detail
          if @resource.send(resource_update_method, account_update_params)
            yield @resource if block_given?
            @data = UserSerializer.new(@resource)
            render json: @data
          else
            render_update_error
          end
        else
          render_update_error_user_not_found
        end
      end

      def destroy
        if @resource
          @resource.destroy if check_role(@resource) == "patient"
          yield @resource if block_given?
          render_destroy_success
        else
          render_destroy_error
        end
      end

      def sign_up_params
        params.permit(*params_for_resource(:sign_up))
      end


      def configure_permitted_parameters
        permitted_parameters = devise_parameter_sanitizer.instance_values['permitted']
        permitted_parameters[:sign_up] << :plan_id << :default_rate << :therapist_id << :added_by << :role_name << :first_name << :last_name << :email << :password << :about_me << :birth_date << :gender << :status << :approved  << :schedule_alert_time << :logo << :phone_number << :cancel_percentage << :per_slot_charges << :practice_name << :time_zone << [therapist_skills: []]   << [profile_picture_attributes: [:item, :media_type]] << [introduction_video_attributes: [:item, :media_type]] << [address_attributes: [:street_address, :zip, :country, :latitude, :longitude, :house_num, :city, :state]] << [social_profiles_attributes: [:social_profile_type, :link]] << [user_insurance_detail_attributes: [:npi, :tax_id, :ssn, :member_id, :group_number, :policy_number]] << [user_payers_attributes: [:payer_id]]
      end

      def configure_account_update_params
        permitted_parameters = devise_parameter_sanitizer.instance_values['permitted']
        permitted_parameters[:account_update] << :plan_id << :therapist_id << :first_name << :last_name << :password << :logo << :password_confirmation << :about_me << :birth_date << :gender << :status << :approved  << :schedule_alert_time << :therapist_type << :phone_number << :cancel_percentage << :per_slot_charges << :practice_name << :time_zone << [therapist_skills: []] << [profile_picture_attributes: [:id, :item, :media_type]] << [introduction_video_attributes: [:id, :item, :media_type]] << [address_attributes: [:id, :street_address, :zip, :country, :latitude, :longitude, :house_num, :city, :state]] << [social_profiles_attributes: [:id, :social_profile_type, :link]] << [user_insurance_detail_attributes: [:id, :npi, :tax_id, :ssn, :member_id, :group_number, :policy_number]] << [user_payers_attributes: [:id, :payer_id]]
      end

      def edit_profile
      end

      def show
        render json: @user
      end

      def update_profile
        @user.update(get_user_params)
        redirect_to edit_profile_path
      end

      def render_update_success
        render json: {
          status: 'success',
          data:   resource_data
        }
      end

      def render_update_error
        render json: {
          status: 'error',
          errors: resource_errors
        }, status: 422
      end

      def render_update_error_user_not_found
        render_error(404, I18n.t('devise_token_auth.registrations.user_not_found'), status: 'error')
      end

      def update_with_password(params, *options)
        current_password = params.delete(:current_password, :passoword, :password_confirmation)

        if params[:password].blank?
          params.delete(:password)
          params.delete(:password_confirmation) if params[:password_confirmation].blank?
        end

        result = if valid_password?(current_password)
          update(params, *options)
        else
          assign_attributes(params, *options)
          valid?
          errors.add(:current_password, current_password.blank? ? :blank : :invalid)
          false
        end

        clean_up_passwords
        result
      end

      def resource_update_method
        if DeviseTokenAuth.check_current_password_before_update == :attributes
          'update_with_password'
        elsif DeviseTokenAuth.check_current_password_before_update == :password && account_update_params.key?(:password)
          'update_with_password'
        elsif account_update_params.key?(:current_password)
          'update_with_password'
        else
          'update_attributes'
        end
      end

      def account_update_params
        params.permit(*params_for_resource(:account_update))
      end

      protected

      def sign_up(resource_name, resource)
        sign_in(resource_name, resource)
      end

      def build_resource(hash = {})
        self.resource = resource_class.new_with_session(hash, session)
      end

      def after_sign_up_path_for(resource)
        if is_navigational_format?
          after_sign_in_path_for(resource)
        end
      end

      def after_inactive_sign_up_path_for(resource)
        scope = Devise::Mapping.find_scope!(resource)
        router_name = Devise.mappings[scope].router_name
        context = router_name ? send(router_name) : self
        context.respond_to?(:root_path) ? context.root_path : "/"
      end

      private

      def find_user
	    	@user = User.find(params[:id])
	    end

      def create_client_consent_forms
        client_consent_forms = params[:consent_forms]
        client_consent_forms.each do |consent_form|
          client_consent_form = ClientConsentForm.find_or_create_by(consent_form_id: consent_form['id'],
                                                therapist_id: resource.therapist_id, patient_id: resource.id)
          client_consent_form.update!(consent_form_content: consent_form['content'], content_values: consent_form['content_values'])
        end
      end
  	end
  end
end
