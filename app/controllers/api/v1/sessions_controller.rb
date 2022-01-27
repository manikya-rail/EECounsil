module Api
	module V1
		class SessionsController < ::DeviseTokenAuth::SessionsController
			include DeviseTokenAuth::Concerns::SetUserByToken
			skip_before_action :verify_authenticity_token
			before_action :set_user_by_token, only: [:destroy]
			respond_to :json

			def new
				super
			end

			def create

  			field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

        @resource = nil
        if field
          q_value = get_case_insensitive_field_from_resource_params(field)

          @resource = find_resource(field, q_value)
        end

        if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
          valid_password = @resource.valid_password?(resource_params[:password])
          if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
            return render_create_error_bad_credentials
          end
          @client_id, @token = @resource.create_token
          @data = UserSerializer.new(@resource)
          @resource.save

          sign_in(:user, @resource, store: false, bypass: false)

          yield @resource if block_given?

          render_create_success
        elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
          if @resource.respond_to?(:locked_at) && @resource.locked_at
            render_create_error_account_locked
          else
            render_create_error_not_confirmed
          end
        else
          render_create_error_bad_credentials
        end
      end

			def destroy
	      # remove auth instance variables so that after_action does not run
	      user = remove_instance_variable(:@resource) if @resource
	      client_id = remove_instance_variable(:@client_id) if @client_id
	      remove_instance_variable(:@token) if @token

	      if user && client_id && user.tokens[client_id]
	      	user.tokens.delete(client_id)
	      	user.save!

	      	yield user if block_given?

	      	render_destroy_success
	      else
	      	render_destroy_error
	      end
	    end

      protected

      def render_create_success
        render json: {
          data: resource_data(resource_json: @data)
        }
      end

      def render_create_error_not_confirmed
        render json: {
          error: "You are not yet approved by admin. After approval, a mail will be sent to your registered email."
        }
      end

	  end
	end
end
