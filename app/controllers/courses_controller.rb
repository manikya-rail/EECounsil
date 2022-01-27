class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_course, only: [:edit, :update, :show]

  def index
    @course_ids = TherapistCourse.all
    @courses = Course.all.as_json(@course_ids)
  end

  def new
    @course = Course.new
    @course.media.new
    @course.course_sessions.new
  end

  def create
    @course = Course.new(get_course_params)
    if @course.save
      redirect_to courses_path, notice: "Course Added Successfully!"
    else
      @course.media.new
      render 'new'
    end
  end

  def show
  end

  def edit
    @course.course_sessions
  end

  def update
    if @course.update(get_course_params)
      #redirect_to courses_path, notice: "Course Updated Successfully!"
      redirect_to request.referrer, notice: "Course Updated Successfully!"
    else
      render 'edit'
    end
  end

  def show_course
    @purchased = TherapistCourse.find_by(course_id: params[:id]).present?
    @course = Course.find(params[:id])
  end

  def destroy
    Course.find(params[:id]).destroy
    redirect_to courses_path, notice: "Course Deleted Successfully!"
  end

  def delete_coursesession_media
    Medium.find(params['id']).destroy
    render json: { success: 'success' }
  end

  private

  def get_course_params
    params.require(:course).permit(
      :name,
      :description,
      :price,
      :free_months,
      course_sessions_attributes: [:id, :course_id, :_destroy, { media_attributes: [:id, :item, :_destroy] }],
      media_attributes: [:id, :item, :_destroy]
    )
  end

  def find_course
      @course = Course.find(params[:id])
  end
end
