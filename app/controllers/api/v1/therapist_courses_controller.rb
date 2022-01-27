module Api
  module V1
    class TherapistCoursesController < ApplicationController
    	include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!, except: [:use_trail]

      def index
        if current_user.roles.first.name == 'guest'
          @therapist_courses = TherapistCourse.where(user_id: current_user.id).map { |therapist_course| therapist_course.course }.uniq
        else
          @therapist_courses = TherapistCourse.where(therapist_id: current_user.id).map { |therapist_course| therapist_course.course }.uniq
        end
        render json: { therapisist_courses: ActiveModel::ArraySerializer.new(@therapist_courses, each_serializer: CourseSerializer) }
      end

      def create
        @response_data = StripeChargesServices.new(payment_params,current_user).call
        if @response_data.id.present?
          tc = TherapistCourse.where(course_id: payment_params[:course_id], therapist_id: current_user.id).first 
          tc = TherapistCourse.create(course_id: payment_params[:course_id], therapist_id: current_user.id) if !tc.present?
          tc.purchased = true
          tc.save!
        end
        render json: @response_data
      end

      def use_trail
        course = Course.find_by_id(payment_params[:course_id])
        free_time = course.free_months.months.from_now if course.free_months.present?
        tc = TherapistCourse.where(course_id: payment_params[:course_id], therapist_id: current_user.id).first
        tc = TherapistCourse.create(course_id: payment_params[:course_id], therapist_id: current_user.id, trail_date: free_time, purchased: false)  if tc.nil?
        can_see = false
        can_see = true if tc.trail_date > DateTime.now
        render json: {data: tc, can_see: can_see}
      end

      private
      def payment_params
        params.permit(:stripeEmail, :stripeToken, :course_id, :amount)
      end	
    end
  end
end
