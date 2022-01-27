class QuestionnairesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_questionnaire, only: [:edit, :destroy, :update]
  # load_and_authorize_resource

  def index
  	@questionnaire = Questionnaire.all
  end

  def new
  	@questionnaire = Questionnaire.new
  end

  def edit
  end

  def create
  	@questionnaire = Questionnaire.new(set_params)
	  if @questionnaire.save
	  	redirect_to questionnaires_path, notice: "Questionnaire Created Successfully!"
	  else
	  	render "new"
	  end
  end

  def update
    if @questionnaire.update(set_params)
  		redirect_to questionnaires_path, notice: "Questionnaire Updated Successfully!"
  	else
  		render "edit"
  	end
  end

  def destroy
  	@questionnaire.destroy
  	redirect_to questionnaires_path, notice: "Questionnaire Deleted Successfully"
  end

  private

  def set_params
    params.require(:questionnaire).permit(:question_type, :question, questionnaire_choices_attributes: [:id, :option, :questionnaire_id, :skill, :_destroy])
  end

  def find_questionnaire
  	@questionnaire = Questionnaire.find(params[:id])
  end

end
