module Api
  module V1
    class SkillsController < ApplicationController
      def index
        render json: Skill.pluck(:name)
      end
    end
  end
end
