module Api
  module V1
    class CoursesController < ApplicationController
      # include DeviseTokenAuth::Concerns::SetUserByToken
      # before_action :authenticate_user!
      # before_action :find_therapist, only: [:index, :get_therapist_course_sessions]
      before_action :find_therapist, only: [:index]
   
      def index
        @therapist_courses = []
        @therapist_courses = @therapist.therapist_courses if @therapist
        @courses = Course.all.as_json(@therapist_courses)
        # @courses = Course.all
        # @active_promo = @therapist.promos.where(active: true).first
        # @code = @active_promo.promo_code if @active_promo
        render json: {courses: @courses} 
      end

      def get_therapist_course_sessions
        # check_course =  @therapist.therapist_courses.find_by(course_id: params[:course_id])
        check_course =  TherapistCourse.find(params[:course_id])
        if check_course.present?
          if check_course.trail_date.present? && check_course.try(:trail_date) > DateTime.now
            @course_sessions = Course.find(params[:course_id]).course_sessions
            return render json: { course_sessions: ActiveModel::ArraySerializer.new(@course_sessions, each_serializer: CourseSessionSerializer) }
          else
            @course_sessions = Course.find(params[:course_id]).course_sessions
            return render json: { course_sessions: ActiveModel::ArraySerializer.new(@course_sessions, each_serializer: CourseSessionSerializer) }
          end
          render json: { message: 'Trail period has ended' }
        else
          render json: { message: 'Sorry you are not purchased this course' }
        end
      end

      private
      
      def find_therapist
        @therapist = Therapist.find(current_user.id) if current_user
      end
    
    end
  end
end
