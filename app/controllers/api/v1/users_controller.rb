module Api
  module V1
    class UsersController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      include ActiveSupport
      before_action :authenticate_user!, except: [:check_for_email, :check_for_url, :check_for_promo, :fetch_time_zones, :update_user_device]
      before_action :find_profile, only: [:profile,:update_user_status, :others_profile, :check_therapist_cc_feature]

      def profile
        if current_user == @profile
          @data = UserSerializer.new(@profile)
          render json: @data
        end
      end

      def get_patient_detail
        if params[:role] == "therapist"
          @therapist = Therapist.find_by_uid(params[:uid])
          if params["schedule_id"].present?
            patient_id = Schedule.find(params["schedule_id"]).patient_id
          else
            patient_id = params[:id]
          end
          @current_patient = @therapist.patients.find_by(id: patient_id)
          if @current_patient
            schedules = Schedule.where(status: "booked", patient_id: @current_patient, therapist_id: @therapist.id).order("created_at asc")
            @schedules = ActiveModel::ArraySerializer.new(schedules, each_serializer: SchedulesSerializer)
            @media_notes = MediaNote.where(patient_id: @current_patient, therapist_id: @therapist.id).order("created_at asc")
            therapist_accessible_features
            slot_charges = TherapistRatePerClient.find_by(therapist_id: @therapist.id, patient_id: patient_id)
            used_schedule_ids = VideoCall.where(receiver_id: @current_patient, sender_id: @therapist.id).pluck(:schedule_id).compact.uniq
            render json: {current_user: @therapist, media_notes: @media_notes.as_json, slot_charges: slot_charges,
                          current_user_patients: @therapist.patients.order("first_name asc").uniq.as_json(include: [:profile_picture, :address]),
                          schedules: @schedules, current_patient: @current_patient.as_json(include: [:profile_picture, :address]),
                          message_accessible: @message_accessible, manual_charging_accessible: @manual_charging_accessible,
                          current_date: Time.now.utc, used_schedule_ids: used_schedule_ids, current_patient_value: true}
          else
            render json: {
                current_patient_value: false
            }
          end
        else
          @patient = Patient.find_by_uid(params[:uid])
          if params["schedule_id"].present?
            therapist_id = Schedule.find(params["schedule_id"]).therapist_id
          else
            therapist_id = params[:id]
          end
          @therapist = Therapist.find(therapist_id)
          # @schedules = Schedule.where(status: "booked", patient_id: @current_patient, therapist_id: @therapist.id)
          @media_notes = MediaNote.where(patient_id: @patient.id, therapist_id: @therapist.id).order("created_at asc")
          render json: {current_user: @patient, media_notes: @media_notes.as_json}
        end
      end

      def get_users_detail_with_schedules
        data = []
        obj = {}
        if params[:role] == "therapist"
          @therapist = Therapist.find_by_uid(params[:uid])
          @patients = @therapist.patients.order("first_name asc").includes(:profile_picture).uniq
          @patients.each do |patient|
            obj["id"] = patient.id
            obj["first_name"] = patient.first_name
            obj["last_name"] = patient.last_name
            obj["profile_pic"] = patient.try(:profile_picture).try(:item).try(:url)
            obj["last_schedule_id"] = patient.schedules.last.id
            data << obj
            obj = {}
          end
          @last_Schedule = @therapist.schedules.where(status: "booked").last
          render json: { users: data, last_schedule:  @last_Schedule }
        else
          @patient = Patient.find_by_uid(params[:uid])
          @therapists = @patient.therapists.order("first_name asc").uniq
          @therapists.each do |therspist|
            obj["id"] = therspist.id
            obj["first_name"] = therspist.first_name
            obj["last_name"] = therspist.last_name
            obj["profile_pic"] = therspist.try(:profile_picture).try(:item).try(:url)
            obj["last_schedule_id"] = therspist.schedules.last.id
            data << obj
            obj = {}
          end
          @last_Schedule = @patient.schedules.where(status: "booked").last
          render json: { users: data, last_schedule:  @last_Schedule }
        end
      end

      def create_manual_charge
        user = User.find(params[:data][:patient_id])
        if user.user_payment_modes.blank? || params[:data][:stripeEmail].present?
          customer = Stripe::Customer.create(email: params[:data][:stripeEmail], source: params[:data][:stripeToken])
          user.user_payment_modes.create(payment_mode: 0, token: customer.id)
        end
        customer_token = user.user_payment_modes.where(payment_mode: "stripe").try(:last).try(:token)
        therapist = Therapist.find(params[:data][:therapist_id])
        if customer_token && therapist.stripe_connect_account_id
          stripe_charge = stripe_charge_create(customer_token, params[:data][:charge_amount], therapist)
          transfer = stripe_transfer_create(params[:data][:charge_amount], stripe_charge.id, therapist.stripe_connect_account_id)
          charge = ScheduleCharge.create(
                  therapist_id: params[:data][:therapist_id],
                  patient_id: params[:data][:patient_id],
                  schedule_id: params[:data][:schedule_id],
                  charge_id: stripe_charge.id,
                  transfer_id: transfer.id,
                  status: "charged",
                  description: params[:data][:description],
                  amount: params[:data][:charge_amount]
                )
        end
        render json: { charge: charge }
      end

      def patient_charges_details
        charges = ScheduleCharge.where(patient_id: params[:id]).as_json(include: [:therapist])
        render json: charges
      end

      def approve_charge
        charge = ScheduleCharge.find(params[:charge_id])
        schedule = Schedule.find(charge.schedule_id)
        patient = schedule.patient
        therapist = schedule.therapist
        customer_token = patient.user_payment_modes.where(payment_mode: "stripe").try(:first).try(:token)
        if customer_token && therapist.stripe_connect_account_id
          stripe_charge = stripe_charge_create(customer_token, charge.try(:amount), therapist)
          transfer = stripe_transfer_create(charge.try(:amount), stripe_charge.id, therapist.stripe_connect_account_id)
          charge.charge_id = stripe_charge.id
          charge.transfer_id = transfer.id
          charge.status = "charged"
          charge.save
        end
        charges = ScheduleCharge.where(patient_id: params[:patient_id]).as_json(include: [:therapist])
        render json: { charges: charges }
      end

      def refund_charge
        charge = ScheduleCharge.find(params[:charge_id])
        refund = Stripe::Refund.create(charge: charge.charge_id)
        charge.update!(status: 'refunded') if refund.status == 'succeeded'
        charges = ScheduleCharge.where(patient_id: params[:patient_id]).as_json(include: [:therapist])
        render json: { charges: charges, msg: 'Refunded Successfully' }
      end


      def get_bank_details
        user = User.find_by_uid(params[:uid])
        render json: { user: user }
      end

      def get_therapist_introductory_video
        therapist = Therapist.find_by_email(params[:uid])
        video = UserMedium.where(user_id: therapist.id, media_type: "introduction_video").last
        if video.present?
          render json: { video_url: video.try(:item).try(:url) }
        else
          render json: { video_url: "" }
        end
      end

      def others_profile
         render json: UserSerializer.new(@profile)
      end

      def update_url
        @user  = User.find_by_id(params[:user_id])
        @user.update(own_url: params[:user][:url])
        return render json: {res: false, errors: @user.errors.messages} if @user.errors.present?
        render json: {res: true, user: @user}
      end

      def search_therapist
        if current_user.therapist_id
          @therapists = User.where(id: current_user.therapist_id)
          return render json: {
            therapists: ActiveModel::ArraySerializer.new(@therapists, each_serializer: SearchTherapistSerializer)
          }
        end
        que_answer =  Patient.find(current_user.id).questionnaire_answers
        questionnaire_choice_id = que_answer.map{ |s| s.questionnaire_choice_id }
        skills = QuestionnaireChoice.where(id: questionnaire_choice_id).map{ |w| w.skill }.uniq
        thera = Therapist.where(status: true, deleted_at: nil).map{ |y| y  if !(y.therapist_skills & skills).empty? }.compact
        match_therapist = thera.present? ? thera : Therapist.where(status: true, deleted_at: nil)
        @therapists = params[:search].present? ? Therapist.where("first_name LIKE :search OR last_name LIKE :search OR email LIKE :search OR :search = ANY(therapist_skills)", search: params[:search]).where(status: true, deleted_at: nil) : match_therapist
        render json: {
          therapists: ActiveModel::ArraySerializer.new(@therapists, each_serializer: SearchTherapistSerializer)
        }
      end

      def update_user_against_therapist
        @user = User.find_by_id(params[:user_id])
        @therapist = User.find_by_id(params[:therapist_id])
        if @user && @therapist.present?
          @user.update(therapist_id:  @therapist.id, logo: @therapist.logo.url )
          schedule = Schedule.where(therapist_id: @therapist.id, patient_id: @user.id).last
          if schedule.nil?
            schedule = Schedule.new(therapist_id: @therapist.id, patient_id: @user.id)
            schedule.skip_validation = true
            schedule.save!
          end
        end
        @data = UserSerializer.new(@user)
        return render json: @data
      end

      def check_for_email
        @user = User.find_by_email(params[:email])
        render json: {found: @user.present?}
      end

      def check_for_promo
        valid = true
        if params[:promo_code].present?
          @promo = PromoCode.find_by_code(params[:promo_code])
          valid = false if @promo.nil?
        end
        render json: {found: valid, promo: @promo}
      end

      def check_for_url
        @user = User.find_by_own_url(params[:url])
        @data = UserSerializer.new(@user)
        return render json: {found: true, user: @data} if @user
        render json: {found: false}
      end

      def my_patients
        # sql = "SELECT th.default_rate AS default_rate, users.* FROM users
        #         INNER JOIN users_roles ON users_roles.user_id = users.id
        #         INNER JOIN roles ON roles.id = users_roles.role_id
        #         LEFT OUTER JOIN therapist_rate_per_clients th ON th.therapist_id = #{params[:id]}
        #         WHERE (roles.name = 'patient') AND users.therapist_id = #{params[:id]} AND users.status = true AND users.deleted_at IS NULL"
        @patients = Therapist.find(params[:id]).patients.where(status: true, deleted_at: nil).uniq
        # @patients = Patient.find_by_sql sql
        render json: { patients: ActiveModel::ArraySerializer.new(@patients.uniq, each_serializer: PatientListsSerializer) }
        # render json: @patients.uniq
      end

      def unscheduled_chat
        if current_user.roles.first.name == "patient"
          schedule = Schedule.where(therapist_id: params[:receiver_id], patient_id: current_user.id, starts_at: nil , ends_at: nil ).first
          if schedule.nil?
            schedule = Schedule.new(therapist_id: params[:receiver_id], patient_id: current_user.id)
            schedule.skip_validation = true
            schedule.save
          end
        else
          schedule = Schedule.where(patient_id: params[:receiver_id], therapist_id: current_user.id, starts_at: nil , ends_at: nil ).first
          if schedule.nil?
            schedule = Schedule.new(patient_id: params[:receiver_id], therapist_id: current_user.id)
            schedule.skip_validation = true
            schedule.save
          end
        end
        render json: schedule
      end

      def my_therapists
        @therapists = Patient.find(params[:id]).therapists.where(approved: true, status: true, deleted_at: nil).uniq
        render json: @therapists
      end

      def payment_details
        @payment_details = Payment.where(paid_by: params[:id])
        render json: @payment_details
      end

      def payout_details
        @payout_details = Payment.where(paid_to: current_user.id)
        render json: @payout_details
      end

      def update_user_status
        status = @profile.status ? false : true
        @profile.address_validate = true
        @profile.update(status: status)
        if @user_role == "therapist" && Therapist.find(@profile.id).schedules.where(status: "booked").present?
          UserMailer.notify_admin(@profile).deliver_later
        end
        render json: @profile
      end

      def create_connect_account
        @response_data   = StripeConnectServices.new(connect_account_params.merge(ip_address: request.remote_ip),current_user).call
        render json: @response_data
      end

      def get_timezone #timezone API
        @timezone = User.find(params[:id]).address.timezone
        render json: @timezone
      end

      def fetch_time_zones
        names = ["Pacific Time (US & Canada)", "Mountain Time (US & Canada)","Eastern Time (US & Canada)", "Central Time (US & Canada)"]
        timezones = TimeZone.all.map(&:name).select{|ele| names.include? ele}.sort
        render json: {timezones: timezones}
      end

      def check_patient_card_details
        user = params[:id].present? ? User.find(params[:id]) : current_user
        render json: { patient_card_present: user.user_payment_modes.present? }
      end

      def check_therapist_cc_feature
        plan = PaymentPlan.find(@profile.plan_id)
        @current_user_features = plan.plan_features.map(&:feature_names)
        accessible = @current_user_features.include? 'Credit Card Processing'
        render json: {accessible: accessible}
      end

      def update_user_device
        user = User.find(params[:user_id]).update!(current_login_device: params[:current_login_device])
        render json: {message: 'success'}
      end

      private

      def find_profile
        @profile = User.find(params[:id])
        @user_role = check_role(@profile)
      end

      def therapist_accessible_features
        if @therapist
          plan = PaymentPlan.find(@therapist.plan_id)
          current_user_features = plan.plan_features.map(&:feature_names)
          @message_accessible = current_user_features.include? 'Client Messaging'
          @manual_charging_accessible = current_user_features.include? 'Manual Charging'
        end
      end

      def connect_account_params
        params.permit(:account_number, :routing_number, :ssn_last_4, :ip_address, :birth_date)
      end

      def stripe_charge_create(customer_token, charge, therapist)
        Stripe::Charge.create(customer: customer_token,
                              amount: charge * 100,
                              description: "Manual Charge for Therapist: #{therapist.first_name} #{therapist.last_name}",
                              currency: 'usd',
                              on_behalf_of: therapist.stripe_connect_account_id, ##CONNECTED_STRIPE_ACCOUNT_ID
                              statement_descriptor: therapist.full_name
                              )
      end

      def stripe_transfer_create(charge, stripe_charge_id, stripe_connect_account_id)
        Stripe::Transfer.create({
                amount: charge * 100,
                currency: "usd",
                source_transaction: stripe_charge_id,
                destination: stripe_connect_account_id, #CONNECTED_STRIPE_ACCOUNT_ID
                })
      end
    end
  end
end
