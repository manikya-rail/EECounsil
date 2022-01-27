class Users::RegistrationsController < Devise::RegistrationsController
  require 'securerandom'
  before_action :generate_random_password, only: [:create_patient, :create_therapist]

  before_action :find_user, only: [:edit_profile, :update_profile, :show, :show_profile]
  before_action :build_nested_form_objects, only: [:new_patient, :new_therapist]
  skip_before_action :verify_authenticity_token, only: :create
  load_and_authorize_resource only: [:new_user, :create_user], class: :User

  def new
    build_resource
    resource.build_address
    resource.build_profile_picture
    resource.build_introduction_video
    yield resource if block_given?
    respond_with resource
  end

  def create
    build_resource(sign_up_params)
    resource
    if resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    else

      resource.build_address
      # resource.user_media.build
      render 'new'
      # redirect_back fallback_location: {resource, message: xxxxxx}
    end
  end

  def show
  end

  def show_profile
  end

  def edit
    resource.build_profile_picture if resource.profile_picture == nil
  end

  def update

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    yield resource if block_given?

    if params[:user][:password].present? && params[:user][:profile_picture_attributes][:item].present?
      successfully_updated = @user.update_with_password(account_update_params)
    elsif params[:user][:password].present?
      successfully_updated = @user.update_with_password(account_update_params.except('profile_picture_attributes'))
    elsif params[:user][:profile_picture_attributes][:item].present?
      successfully_updated = @user.update_without_password(account_update_params.except('password','password_confirmation','current_password'))
    else
      successfully_updated = @user.update_without_password(account_update_params.except('password','password_confirmation','current_password','profile_picture_attributes'))
    end

    if successfully_updated
      set_flash_message :notice, :updated
      sign_in @user, bypass_sign_in: true
      redirect_to edit_user_registration_path
    else
      render 'edit'
    end
  end

  def new_patient
  end

  def new_therapist
  end

  def create_patient
    @user = User.new(get_user_params)
    if @user.save
      @role_name = get_user_params[:role_name] #to redirect to the therapist/patient index after create
      redirect_to users_index_path(role_name: @role_name)
    else
      @user.build_address(get_user_params[:address_attributes])
      render 'new_patient'
    end
  end

  def create_therapist
    @user = User.new(get_user_params)
    if @user.save
      @role_name = get_user_params[:role_name] #to redirect to the therapist/patient index after create
      redirect_to users_index_path(role_name: @role_name)
    else
      @user.build_address(get_user_params[:address_attributes])
      render 'new_therapist'
    end
  end

  def edit_profile
    resource.build_profile_picture if resource.profile_picture == nil
  end

  def update_profile
    if @user.update(get_user_params)
      redirect_to edit_profile_path
    else
      render "edit_profile"
    end
  end

  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message! :notice, :destroyed
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def get_user_params
    params.require(:user).permit(:email, :first_name,
                                    :last_name, :birth_date,
                                    :gender, :phone_number,
                                    :password, :password_confirmation,
                                    :role_name, :added_by, :therapist_type,
                                    :status, :approved, therapist_skills: [],
                                    profile_picture_attributes: [:id, :item, :media_type],
                                    introduction_video_attributes: [:id, :item, :media_type],
                                    address_attributes: [:id, :street_address, :country, :zip, :latitude, :longitude])
  end

  def generate_random_password
    random_password = SecureRandom.alphanumeric(8)
    params[:user][:password] = random_password
    params[:user][:password_confirmation] = random_password
  end

  def build_nested_form_objects
    @user = User.new
    @user.build_profile_picture
    @user.build_introduction_video
    @user.build_address
  end
end
