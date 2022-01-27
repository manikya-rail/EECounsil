module Api
  module V1
    class VideosController < ApplicationController
      before_action :videos, only: :index

      def index
        render json: {videos: ActiveModel::ArraySerializer.new(@videos, each_serializer: VideoSerializer)}
      end

      private
      def videos
        @videos = Video.where(home_intro_video: true)
      end
    end
  end
end
