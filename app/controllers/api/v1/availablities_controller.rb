module Api
  module V1
    class Api::V1::AvailablitiesController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!
      before_action :find_therapist, only: [:create, :get_available_days]
      before_action :fetch_current_user_features, only: [:get_available_days]

      def create
        @availablity = @therapist.availablities.find_by(get_availablities_params.slice('start_day'))
        if @availablity && @availablity.update(get_availablities_params)
          render json: @availablity
        elsif @availablity && !@availablity.update(get_availablities_params)
          render json: @availablity.errors
        else
          @availablity = @therapist.availablities.build(get_availablities_params)
          if @availablity.save
            render json: @availablity
          else
            render json: @availablity.errors
          end
        end
      end

      def get_available_days
        can_patient_book_appointment = ['Automated Scheduling','Automated Billing'].any? {|ele| @current_user_features.include? ele}
        if params[:end_date].present?
          @available_days = @therapist.available_days.includes('available_slots').references('available_slots').where(' available_date BETWEEN ? AND ?', params[:start_date].to_date, params[:end_date].to_date)..group('available_days.id ,available_slots.id').having('count(available_slots.id) > 0')
        else
          @available_days = @therapist.available_days.includes('available_slots').references('available_slots').where(' available_date >= ?', params[:start_date].to_date).order(:created_at).group('available_days.id ,available_slots.id').having('count(available_slots.id) > 0')
        end
        render json: {available_days: ActiveModel::ArraySerializer.new(@available_days, each_serializer: AvailableDaySerializer), can_patient_book_appointment: can_patient_book_appointment}
      end

      def get_clone_of_availablity
        @old_availablity = Availablity.find(params[:id])
        @availablity = @old_availablity.dup
        @availablity.days = @old_availablity.available_days.first(7).pluck(:available_date).map do |day|
                                day.wday.to_s
                            end.uniq
        @availablity.start_day = params[:start_date]
        @availablity.save
        render json: @availablity
      end

      def destroy
        @availablity = Availablity.find_by(id: params[:id], therapist_id: params[:therapist_id])
        @availablity.destroy
      end

      private

      def fetch_current_user_features
        current_user ||= User.find(params[:current_user_id])
        plan_id = current_user.roles.first.name == 'patient' ? User.find(current_user.therapist_id || params[:therapist_id]).plan_id : current_user.plan_id
        plan = PaymentPlan.find(plan_id)
        @current_user_features = plan.plan_features.map(&:feature_names)
      end

      def get_availablities_params
        params.require(:availablity).permit(:therapist_id, :by_period, :start_time, :end_time, :start_day, :unavailable_start_time, :unavailable_end_time,   days: [])
      end

      def find_availablity
        @availablity = Availablity.find_by(id: params[:id])
        @available_days = @availablity.available_days
      end

      def find_therapist
        @therapist = Therapist.find(params[:therapist_id])
      end

    end
  end
end
