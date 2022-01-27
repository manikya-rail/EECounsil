module Api
  module V1
    class SchedulesController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!
      before_action :find_current_user_role, only: [:index]
      before_action :find_schedule, only: [:cancel, :book, :complete]
      skip_before_action :authenticate_user!, only:[:request_demo]
      before_action :fetch_current_user_features, only:[:electronic_notes, :index]

      def index
        if @user
          if ['Automated Scheduling','Automated Billing'].any? {|ele| @current_user_features.include? ele} || @user.roles.first.name == 'patient'
            if params[:start_date].present? && params[:end_date].present?
              start_date, end_date = params[:start_date], params[:end_date]
              schedules = @user.schedules.where.not(starts_at: nil, ends_at: nil).where('schedule_date BETWEEN ? AND ?', start_date, end_date).map{ |d| d if (d.therapist.deleted_at.blank? && d.patient.deleted_at.blank? && d.therapist.status == true && d.patient.status == true) }.compact
              @schedules = params[:status].present? ? schedules.where(status: status) : schedules
            elsif params[:status].present?
              @schedules = @user.schedules.where.not(starts_at: nil, ends_at: nil).where(status: params[:status]).map{ |d| d if (d.therapist.deleted_at.blank? && d.patient.deleted_at.blank? && d.therapist.status == true && d.patient.status == true )}.compact
            else
              @schedules = @user.schedules.where.not(starts_at: nil, ends_at: nil).map{ |d| d if (d.therapist.deleted_at.blank? && d.patient.deleted_at.blank? && d.therapist.status == true && d.patient.status == true) }.compact
            end
            render json: @schedules
          else
            render json: {errors: 'Please upgrade your plan for this feature to be included'}
          end
        else
          render json: { message: "Can't find the user" }
        end
      end

      def note_messages
        schedule = Schedule.find_by_id(params[:schedule_id])
        note = ElectronicNote.note_of_schedule(schedule)
        render json: {content: note.content}
      end

      def electronic_notes
        if @current_user_features.include? 'Electronic Client Notes'
          note = ElectronicNote.note_between_patient_therapist(params[:patient_id], params[:therapist_id])
          render json: {content: note.content}
        else
          render json: {errors: 'Please upgrade your plan for this feature to be included'}
        end
      end

      def save_note
        note = ElectronicNote.note_between_patient_therapist(params[:video][:patient_id], params[:video][:therapist_id])
        note.content = params[:video][:content]
        note.save!
        render json: note.content
      end

      def get_users_shared_notes
        notes = UserNote.where(patient_id: params[:patient_id], therapist_id: params[:therapist_id])
        render json: {notes: notes.as_json}
      end

      def save_user_notes
        recipient_id = params["notes"]["role"] == "patient" ? params["notes"]["therapist_id"] :  params["notes"]["patient_id"]
        role = params["notes"]["role"] == "patient"
        note = UserNote.create(recipient_id: recipient_id,
          patient_id: params[:notes][:patient_id],
          therapist_id: params[:notes][:therapist_id],
          content: params[:notes][:content],
          action: "usernotes"
        )
        render json: {note: note}
      end

      def create
        sch_params = params[:schedule]
        @schedule = Schedule.new(get_schedule_params)
        slot = AvailableSlot.where(id: sch_params[:slot_id], status: 'available').first
        if slot.nil?
          return render json: {error: 'Already booked slot'}
        end
        @schedule.starts_at = slot.start_time
        @schedule.ends_at = slot.end_time
        plan = PatientPackagePlan.find_by_id(sch_params[:patient_package_plan_id])
        @schedule.skip_validation = true if !plan
        if @schedule.save!
          recipient_id = current_user.id == @schedule.patient_id ? @schedule.therapist_id : @schedule.patient_id
          Notification.create(recipient: User.find(recipient_id), user: current_user, action: "notificationaction", schedule_type: "scheduled", notifiable: User.find(recipient_id), schedule_id: @schedule.id)
          slot.update(status: 'unavailable')
          plan.increment!(:completed_count) if plan
          plan.decrement!(:remaining_count) if plan
          render json: @schedule
          Schedule.schedule_update(@schedule,current_user, 'new')
        else
          render json: @schedule.errors
        end
      end

      def get_schedule
        schedule = Schedule.find_by_id(params[:schedule_id])
        render json: schedule
      end

      def update
        @schedule = Schedule.find(params[:id])
        @schedule.status = "scheduled"
        @schedule.skip_validation = true
        if @schedule.update(get_schedule_params)
          render json: @schedule
          Schedule.schedule_update(@schedule,current_user, 'update')
        else
          render json: @schedule.errors
        end
      end

      def cancel
        if @schedule[:patient_package_plan_id].present?
          plan = PatientPackagePlan.find(@schedule[:patient_package_plan_id])
        end
        if @schedule.cancel!
          recipient_id = current_user.id == @schedule.patient_id ? @schedule.therapist_id : @schedule.patient_id
          Notification.create(recipient: User.find(recipient_id), user: current_user, action: "notificationaction", schedule_type: "canceled", notifiable: User.find(recipient_id), schedule_id: @schedule.id)
          if @schedule[:patient_package_plan_id].present?
            plan.decrement!(:completed_count)
            plan.increment!(:remaining_count)
          end
          render json: { success: 'Canceled' }
          Schedule.schedule_update(@schedule,current_user, 'new')
        else
          render json: { error: 'Not Canceled' }
        end
      end

      def book
        if @schedule.book!
          @schedule.update!(procedure_code_id: params[:procedure_code]) if @schedule.procedure_code_id.nil? && params[:procedure_code].present?
          recipient_id = current_user.id == @schedule.patient_id ? @schedule.therapist_id : @schedule.patient_id
          Notification.create(recipient: User.find(recipient_id), user: current_user, action: "notificationaction", schedule_type: "approved", notifiable: User.find(recipient_id), schedule_id: @schedule.id)
          render json: { success: 'Approved' }
          Schedule.schedule_update(@schedule,current_user, 'new')
        else
          render json: { error: 'Not Approved' }
        end
      end

      def complete
        if @schedule.status == 'partial_completed'
          if @schedule.complete!
            recipient_id = current_user.id == @schedule.patient_id ? @schedule.therapist_id : @schedule.patient_id
            Notification.create(recipient: User.find(recipient_id), user: current_user, action: "notificationaction", schedule_type: "completed", notifiable: User.find(recipient_id), schedule_id: @schedule.id)
            render json: { success: 'Completed' }
            Schedule.schedule_update(@schedule,current_user, 'new')
          else
            render json: { error: 'Not Completed' }
          end
        else
          if @schedule.partial_complete!
            recipient_id = current_user.id == @schedule.patient_id ? @schedule.therapist_id : @schedule.patient_id
            Notification.create(recipient: User.find(recipient_id), user: current_user, action: "notificationaction", schedule_type: "partial completed", notifiable: User.find(recipient_id), schedule_id: @schedule.id)
            render json: { success: 'Partial Completed' }
          else
            render json: { error: 'Not Completed' }
          end
        end
      end

    def request_demo
      admin_emails = []
      users = User.all
      users.each do |user|
        if user.roles.first.name == "admin"
          admin_emails << user.email
        end
      end
      UserMailer.request_demo(params, admin_emails).deliver_now
      begin
        mailchimp = Mailchimp::API.new('1b9363724e128f14743c2e7c3ab6799c-us20')
        chimp = mailchimp.lists.batch_subscribe('21c2a74d8f',[ "Email" =>
          { "email" => params[:email] , 'euid': '123' },
          :merge_vars => { "FNAME" => params[:fullName],
          "USERTYPE" => "Demo Requester" }]
          )
      rescue Exception => e
        puts e
      end
      render json: { msg: 'Your request has been send to admin!' }
    end

    def fetch_procedures
      procedure_codes = ProcedureCode.all
      render json: {procedure_codes: ActiveModel::ArraySerializer.new(procedure_codes, each_serializer: ProcedureCodeSerializer)}
    end

    def fetch_used_schedules
      used_schedule_ids = VideoCall.where(receiver_id: params[:patient_id], sender_id: params[:therapist_id]).pluck(:schedule_id).compact.uniq
      schedules = Schedule.where(status: "booked", patient_id: params[:patient_id], therapist_id: params[:therapist_id]).order("created_at asc")
      render json: { used_schedule_ids: used_schedule_ids, current_date: Time.now.utc, schedules: ActiveModel::ArraySerializer.new(schedules, each_serializer: SchedulesSerializer) }
    end

    def fetch_uncharged_schedules
      schedules = Schedule.where(patient_id: params[:patient_id], therapist_id: params[:therapist_id], status: 'booked', scheduled_by: 'therapist')
      charged_schedules = ScheduleCharge.where(patient_id: params[:patient_id], therapist_id: params[:therapist_id], status: 'charged')
      uncharged_schedules = schedules - charged_schedules
      render json: {uncharged_schedules: ActiveModel::ArraySerializer.new(uncharged_schedules, each_serializer: SchedulesSerializer)}
    end

     private

      def fetch_current_user_features
        # current_user ||= User.find(params[:current_user_id])
        current_user = @user
        plan_id = current_user.roles.first.name == 'patient' ? User.find(@user.therapist_id).plan_id : @user.plan_id
        plan = PaymentPlan.find(plan_id)
        @current_user_features = plan.plan_features.map(&:feature_names)
      end


      def find_schedule
        @schedule = Schedule.find(params[:schedule_id])
        @schedule.skip_validation = true
      end

      def find_current_user_role
        @user = check_role(current_user) == 'patient' ? Patient.find(current_user.id) : Therapist.find(current_user.id)
      end

      def get_schedule_params
        params.require(:schedule).permit(:patient_id, :therapist_id, :starts_at, :ends_at, :schedule_date, :status, :patient_package_plan_id, :scheduled_by, :procedure_code_id)
      end

    end
  end
end
