class UserSerializer < ActiveModel::Serializer
attributes :id, :first_name, :last_name, :email, :gender, :status, :birth_date, :added_by, :phone_number,:cancel_percentage,
           :per_slot_charges, :schedule_alert_time, :stripe_connect_account_id, :stripe_bank_account_id, :therapist_skills,
           :address, :profile_picture, :introduction_video, :social_profiles, :own_url, :therapist_id, :logo, :therapist_url,
           :plan_id, :logo_url, :payment_plan, :therapist_type, :planStatus, :about_me, :therapist_name, :practice_name,
           :time_zone, :current_login_device, :user_payers, :user_insurance_details, :therapist_payers

  has_one :roles


  def therapist_url
  	if object.therapist_id.present?
  		user = User.find_by_id(object.therapist_id)
  		return user.own_url if user
  		return nil
  	else
  		return nil
  	end
  end

  def logo_url
  	if object.therapist_id.present?
  		user = User.find_by_id(object.therapist_id)
  		return user.logo.url if user
  		return nil
  	end
  	return nil

  end

  def payment_plan
    if object.present? && object.roles[0].name == "therapist"
      payment = PaymentPlan.where(id: object.plan_id)
      return payment if payment
      return nil
    end
    return nil
  end

  def therapist_type
    if object.present?
      return object.try(:therapist_type)
    end
  end

  def planStatus
    if object.present? && object.roles[0].name == "therapist"
      payment = PaymentPlan.find(object.plan_id)
      free_trail_days = (Date.today.to_date - object.created_at.to_date).to_i
      return 'expired' if payment.amount == 0 && free_trail_days > 30
      return 'payment_pending' if payment.amount > 0 && object.subscription_id.nil?
    end
  end

  def therapist_name
    if object.present? && object.roles[0].name == "patient"
      return Therapist.find(object.therapist_id).full_name if object.therapist_id.present?
    end
  end

  def user_payers
    if object.present? 
      user_payers = object.user_payers
      return  ActiveModel::ArraySerializer.new(user_payers, each_serializer: UserPayerSerializer)
    end
  end

  def user_insurance_details
    if object.present?
      user_insurance_details = [object.user_insurance_detail]
      return  ActiveModel::ArraySerializer.new(user_insurance_details, each_serializer: UserInsuranceDetailSerializer)
    end
  end

  def therapist_payers
    if object.present? && object.roles[0].name == 'patient'
      ids = UserPayer.where(user_id: object.therapist_id)&.pluck(:payer_id)
      therapist_payers = Payer.select(:id, :payer_id, :payer_name).where(id: ids)
      therapist_payers_ary = therapist_payers.present? ? ActiveModel::ArraySerializer.new(therapist_payers, each_serializer: PayerSerializer) : []
      return therapist_payers_ary
    end
  end
end


