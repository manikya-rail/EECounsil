module Api
  module V1
    class UnavailabilitiesController < ApplicationController
      # include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!
      before_action :find_unavailability, only: [:update, :destroy]
      before_action :find_available_days, only: :create

      def create
        already_exits = 0
        unless @available_days.nil?
          @available_days.each do |day|
            start_time, end_time  = day.start_time, day.end_time
            day.unavailabilities.each do |unavailability|
              if time_between(params[:unavailability][:unavailable_start_time], unavailability.unavailable_start_time,unavailability.unavailable_end_time,1) || time_between(params[:unavailability][:unavailable_end_time], unavailability.unavailable_start_time,unavailability.unavailable_end_time,1) || time_between(params[:unavailability][:unavailable_start_time],start_time,end_time,2) || time_between(params[:unavailability][:unavailable_end_time],start_time,end_time,2)
                already_exits = 1
                break
              end
            end

            if already_exits == 0
              day.unavailabilities.create(get_unavailability_params)
              render json: {message: 'Unavailability Created'}
            else
              render json: {error: 'You are already unavailable at this TimeSlot'}
            end
          end
        else
          render json: {message: 'No available day found.'}
        end
      end

      def update
        @unavailability.update(get_unavailability_params)
        render json: @unavailability
      end

      def destroy
        @unavailability.destroy
      end

      private

      def get_unavailability_params
        params.require(:unavailability).permit(:unavailable_start_time, :unavailable_end_time)
      end

      def find_available_days
        @availablity = Availablity.find(params[:availablity_id])
        @available_days = @availablity.available_days.where('available_date BETWEEN ? AND ?',params[:unavailability][:unavailable_start_date].to_date,params[:unavailability][:unavailable_end_date].to_date)
      end

      def find_unavailability
        @unavailability = Unavailability.find(params[:id])
      end

      def time_between(time, start_time, end_time,type)
        status = time.between?(start_time.strftime("%H:%M"), end_time.strftime("%H:%M"))
        type == 1 ? status : !status
      end
    end
  end
end

