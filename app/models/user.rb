class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  attr_accessor :role_name, :address_validate, :default_rate

  after_create :assign_user_role
  before_save -> { skip_confirmation! }
  after_create :send_mail
  after_create :send_mail
  after_create :subscribe_to_list
  after_create :update_patient_id
  after_create :send_email_for_premium_plan

  enum gender: [:male, :female]
  mount_uploader :logo, MediaUploader

  has_one :profile_picture,-> { where media_type: 'profile_picture'}, class_name: 'UserMedium', dependent: :destroy
  has_one :introduction_video,-> { where media_type: 'introduction_video'}, class_name: 'UserMedium', dependent: :destroy
  has_one :address, dependent: :destroy
  has_one :user_insurance_detail, dependent: :destroy
  has_one :payment_plan
  has_many :social_profiles, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :user_payment_modes
  has_many :payments, dependent: :destroy, foreign_key: 'paid_by'

  has_many :payers, :through => :user_payers
  has_many :user_payers, dependent: :destroy
  validates :first_name, :last_name, presence: true
  # validates :address, presence: true, if: :address_validate_check
  validates_uniqueness_of :own_url, if: -> {own_url.present?}
  accepts_nested_attributes_for :profile_picture, reject_if: :all_blank#, allow_destroy: true
  accepts_nested_attributes_for :introduction_video, reject_if: :all_blank#, allow_destroy: true
  accepts_nested_attributes_for :address, reject_if: :all_blank#, allow_destroy: true
  accepts_nested_attributes_for :social_profiles, reject_if: :all_blank
  accepts_nested_attributes_for :user_insurance_detail, reject_if: :all_blank#, allow_destroy: true
  accepts_nested_attributes_for :user_payers, reject_if: :all_blank#, allow_destroy: true

  def self.send_auto_response_mail
    @users = User.where("? <= created_at AND created_at <= ?", APP_CONFIG['AUTO_RESPONSE_EMAIL_DAYS'].days.ago.beginning_of_day, APP_CONFIG['AUTO_RESPONSE_EMAIL_DAYS'].days.ago.end_of_day)
    @users.each do |user|
      #full logic is raimaing and will be completed after making associations with packages.
      if user.roles.first.name == 'patient' && Patient.find(user.id).patient_packages.blank?
        UserMailer.autoresponce_mail(user).deliver!
      end
    end
  end

  def full_name
    [self.first_name, self.last_name].compact.join(' ').try(:titleize)
  end

  def name_with_email
    [self.full_name, self.email].compact.join(', ')
  end

  def subscribed_plan
    @plan = PaymentPlan.where(stripe_plan_id: self.stripe_plan_id)
    @plan
  end

  def active_for_authentication?
    super && self.approved? && self.deleted_at.blank?
  end

  def subscribe_to_list
    begin
      mailchimp = Mailchimp::API.new('1b9363724e128f14743c2e7c3ab6799c-us20')
      mailchimp.lists.batch_subscribe('21c2a74d8f',[ "Email" =>
        { "email" => email , 'euid': '123' },
        :merge_vars => { "FNAME" => first_name, "LNAME" =>
          last_name,
        "USERTYPE" => role_name.titleize }]
        )
    rescue Exception => e
      puts e
    end
  end

  def update_patient_id
    if self.roles.first.name == 'patient'
      TherapistRatePerClient.find_or_create_by!(email: self.email, therapist_id: self.therapist_id, patient_id: self.id).update(default_rate: self.default_rate)
    end
  end

  def send_email_for_premium_plan
    if self.roles.first.name == 'therapist'
      plan = PaymentPlan.find(self.plan_id)
      current_user_features = plan.plan_features.map(&:feature_names)
      if ['Dedicated Business Phone Line', 'Online Faxing System'].any? {|ele| current_user_features.include? ele}
        UserMailer.notify_admin_about_premium_plan_user(self).deliver!
      end
    end
  end

  def register_therapist_with_zoom
    @access_token = ZoomIntegration.where(config_name: 'ZOOM_OAUTH_ACCESS_TOKEN').first.value
    response_code = create_zoom_user
    if response_code == 124
      @access_token = ZoomIntegration.get_refresh_token
      response_code = create_zoom_user
    end
    return response_code
  end

  def self.send_promocode_mail
    payment_plan_id = PaymentPlan.find_by(amount: 0).id
    free_trial_users = Therapist.where(plan_id: payment_plan_id)
    free_trial_users.each do |user|
      days_diff = (DateTime.now.utc - user.created_at.utc)/(60*60*24)
      promo_value = get_promo_value(days_diff)
      if promo_value
        p "***#{user.email} --- #{promo_value}****"
        promo_code = PromoCode.find_by(promo_type: 'Percentage', promo_value: promo_value)
        UserMailer.notify_therapist_about_promo(user, promo_code).deliver!
      end
    end
  end

  private

  def assign_user_role
    add_role role_name
  end

  def send_mail
    Rails.logger.info "*"*100
    Rails.logger.info self.password
    if added_by.present? && User.find(added_by).roles.first.name == "admin"
      UserMailer.login_email(self).deliver!
    else
      UserMailer.welcome_email(self).deliver! if self.roles.first.name == 'therapist'
      if self.roles.first.name == 'patient'
        therapist = Therapist.find(self.therapist_id)
        UserMailer.notify_therapist_about_client_register(self.full_name, therapist).deliver! if therapist
      end
    end
  end

  def verify_role_name
    unless Role.all.pluck(:name).include?(role_name)
      errors.add(:user, "Invalid Role Name")
    end
  end

  def address_validate_check
    self.roles.present? && self.roles.first.name != 'admin' && self.address_validate != true
  end

  def create_zoom_user
     headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + @access_token
      }
    user_request_hsh = {
            "action": "create",
            "user_info": {
              "email": self.email,
              "type": 1,
              "first_name": self.first_name,
              "last_name": self.last_name
            }
      }
    uri = URI.parse("https://api.zoom.us/v2/users")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, headers)
    req.body = user_request_hsh.to_json
    user_response = http.request(req)
    self.update!(is_zoom_user: true) if user_response.code == '201'
    Rails.logger.info "----------------OP:------------------#{user_response.body} ---------------------------------------"
    return JSON.parse(user_response.body)['code']
  end

  def self.get_promo_value(days_diff)
    case days_diff.to_i
    when 22
      promo_value = 15
    when 32
      promo_value = 20
    when 45
      promo_value = 25
    when 60
      promo_value = 30
    end
    promo_value
  end
end
