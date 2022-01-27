class SkillsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_skill, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: SkillDatatable.new(params) }
    end
  end

  def new
    @skill = Skill.new
  end

  def create
    @skills = []
    skills = true
    params_skills[:name].each do |name|
      if name.blank?
        skills = false
        break
      else
        @skills << Skill.new(name: name)
      end
    end
    if skills == false
      flash.now[:alert] = "Skills can't be blank"
      render "new"
    else
      @skills.each(&:save)
      redirect_to skills_path
    end
  end

  def edit
  end

  def update
    if  @skill.update(name: params[:skill][:name])
      redirect_to skills_path
    else
      flash.now[:alert] = "Skills can't be blank"
      render "edit"
    end
  end

  def destroy
    @skill.destroy
    respond_to do |format|
      format.html{ redirect_back fallback_location: skills_path}
      format.js
    end
  end

  private
    def find_skill
      @skill = Skill.find(params[:id])
    end
    def params_skills
      params.require(:skill).permit(name: [])
    end
end
