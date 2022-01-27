module Api
  module V1
    class MessagesController < ApplicationController
      # before_action :authenticate_user!, only: [:index]

      def index
        @sent_msgs, @received_msgs = [], []
        @user = User.find_by_uid(params[:uid]) if params[:uid].present?
        if @user.present?
          params[:all_messages] ? fetch_all_messages : fetch_msg_from_schedules
          if @user.roles.first.name == 'patient'
            @schedules = Patient.find_by_uid(params[:uid]).schedules.where(status: "booked").as_json(include: [:therapist])
            @schedule = Schedule.find_by(id: params[:schedule_id]).as_json(include: [:therapist]) if params[:schedule_id]
          else
            @schedules = Therapist.find_by_uid(params[:uid]).schedules.where(status: "booked").as_json(include: [:patient])
            @schedule = Schedule.find_by(id: params[:schedule_id]).as_json(include: [:patient]) if params[:schedule_id]
          end
          all_msg = (@sent_msgs.flatten + @received_msgs.flatten).sort_by(&:created_at)
          all_messages = ActiveModel::ArraySerializer.new(all_msg, each_serializer: MessageSerializer)
          sent_msgs = ActiveModel::ArraySerializer.new(@sent_msgs.flatten, each_serializer: MessageSerializer)
          received_msgs = ActiveModel::ArraySerializer.new(@received_msgs.flatten, each_serializer: MessageSerializer)
        end
        render json: { messages: all_messages, sent_msgs: sent_msgs, received_msgs: received_msgs, schedules: @schedules, schedule_detail: @schedule }
      end

      def create
        @message = Message.new(get_message_params)
        @message.save ? (render json: @message) : (render json: @message.errors)
      end

      def video_call
        @message = VideoCall.new(video_call_params)
        schedule = video_call_params[:schedule_id] ? Schedule.find(video_call_params[:schedule_id]) : Schedule.new(therapist_id: video_call_params[:sender_id], patient_id: video_call_params[:receiver_id])
        schedule.skip_validation = true
        if schedule.schedule_date.nil?
          schedule.update!(status: 'booked', scheduled_by: 'therapist', schedule_date: Time.now.utc, starts_at: Time.now.utc, ends_at: Time.now.utc + 1.hours)
        else
          current_schedule = DateTime.now.utc.between?(schedule.starts_at.utc, schedule.ends_at.utc)
          unless current_schedule
            schedule = Schedule.new(therapist_id: video_call_params[:sender_id], patient_id: video_call_params[:receiver_id])
            schedule.skip_validation = true
            schedule.update!(status: 'booked', scheduled_by: 'therapist', schedule_date: Time.now.utc, starts_at: Time.now.utc, ends_at: Time.now.utc + 1.hours)
          end
        end
        @message.schedule_id = schedule.id unless video_call_params[:schedule_id]
        @message.save ? (render json: @message) : (render json: @message.errors)
      end

      def media_notes
        therapist_id = params["message"]["therapist_id"]
        if params["message"]["therapist_id"].present? && params["message"]["therapist_id"].length > 5
          therapist_id = Therapist.find_by_email(params["message"]["therapist_id"]).id
        end
        if params["message"]["role"] == "therapist"
          user_id = therapist_id
          recipient_id = params["message"]["patient_id"]
        elsif params["message"]["role"] == "patient"
          user_id = params["message"]["patient_id"]
          therapist_id = Patient.find(params["message"]["patient_id"]).therapist_id
          recipient_id = therapist_id
        else
          user_id = params["message"]["patient_id"]
          recipient_id = therapist_id
        end
        @media_notes = MediaNote.new(item: params["message"]["item"], patient_id: params["message"]["patient_id"], therapist_id: therapist_id, user_id: user_id, recipient_id: recipient_id, action: "medianotes")
        if @media_notes.save
          render json: { media_notes: @media_notes.as_json, status: 200 }
        else
          render json: { media_notes: @media_notes.errors, status: 500 }
        end
      end

      def end_call
        video = VideoCall.find(params[:video][:video_call_id])
        ActionCable.server.broadcast "notifications:#{video.sender_id}", video.as_json.merge(action: 'callendaction', media: [],caller: video.send(:sender) )
        ActionCable.server.broadcast "notifications:#{video.receiver_id}", video.as_json.merge(action: 'callendaction', media: [],caller: video.send(:sender) )
        render json: video.id
      end

      def note_on_video_call
        schedule  = Schedule.find_by_id(params[:schedule_id])
        schedule.build_electronic_note.save if !schedule.electronic_note.present?
        note =schedule.electronic_note
        note.content = params[:video][:content]
        note.save!
        note = ElectronicNote.note_of_schedule(schedule)
        note.content = params[:video][:content]
        note.save!
        @video  = VideoCall.find_by_id(params[:video][:id])
        @video.message_content = params[:video][:content]
        @video.save
        render json: @video.message_content
      end

      def destroy
        schedule = Schedule.find_by_id(params[:schedule_id])
        unless schedule.messages.empty?
          Message.where(schedule_id: schedule.id).delete_all
          render json: {message: 'Chat is cleared'}
        else
          render json: {message: 'Already cleared.'}
        end
      end

      def notifications
        user = User.find_by_uid(params[:uid])
        notifications = Notification.where(user_id: user.id).order("created_at asc") if user.present?
        render json: notifications
      end

      def fetch_documents
        if params[:therapist_id].present?
          sent_docs = MediaNote.where(user_id: params[:therapist_id]).where.not(recipient_id: nil)
          recieved_docs = MediaNote.where(recipient_id: params[:therapist_id])
        else
          sent_docs = MediaNote.where(user_id: params[:patient_id]).where.not(recipient_id: nil)
          recieved_docs = MediaNote.where(recipient_id: params[:patient_id])
        end
        render json: { sent_documents: ActiveModel::ArraySerializer.new(sent_docs, each_serializer: DocumentSerializer),
                       recieved_documents: ActiveModel::ArraySerializer.new(recieved_docs, each_serializer: DocumentSerializer) }
      end

      private

      def get_message_params
        params.require(:message).permit(:sender_id, :receiver_id, :message_content, :schedule_id,
                                         :meeting_id, :join_url, :host_id,
                                         media_attributes: [:id, :item, :_destroy])
      end

      def video_call_params
        params.require(:video).permit(:sender_id, :receiver_id, :message_content, :schedule_id,
                                      :meeting_id, :join_url, :host_id,
                                       media_attributes: [:id, :item, :_destroy])

      end

      def fetch_all_messages
        @sent_msgs << Message.where(sender_id: @user.id).where.not(message_content: ['', nil]).order(:created_at)
        @received_msgs << Message.where(receiver_id: @user.id).where.not(message_content: ['', nil]).order(:created_at)
      end

      def fetch_msg_from_schedules
        if params[:all_messages] == "true"
          curr_schedule = Schedule.find_by(id: params[:schedule_id])
          if curr_schedule
            all_schedules = Schedule.where(therapist_id: curr_schedule.therapist_id, patient_id: curr_schedule.patient_id).order("created_at asc")
            all_schedules.each do |schedule|
              @sent_msgs << Message.where(schedule_id: schedule.id, sender_id: @user.id, type: nil).where.not(message_content: ['', nil]).order(:created_at)
              @received_msgs << Message.where(schedule_id: schedule.id, receiver_id: @user.id, type: nil)
            end
          end
        else
          @sent_msgs << Message.where(schedule_id: params[:schedule_id], sender_id: @user.id, type: nil).where.not(message_content: ['', nil]).order(:created_at)
          @received_msgs << Message.where(schedule_id: params[:schedule_id], receiver_id: @user.id, type: nil).where.not(message_content: ['', nil]).order(:created_at)
        end
      end
    end
  end
end
