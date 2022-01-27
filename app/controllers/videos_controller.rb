class VideosController < ApplicationController
  before_action :authenticate_user!

  def index
    @videos = Video.all
  end

  def new
    @video = Video.new
    @video.build_media
  end

  def create
    @video = Video.new(get_video_params)
    if @video.save
      redirect_to videos_path
    else
      @video.build_media
      render 'new'
    end
  end

  def show
    @video = Video.find(params[:id])
  end

  def destroy
    Video.find(params[:id]).destroy
    redirect_to videos_path
  end

  private
  def get_video_params
    params.require(:video).permit(:description, :home_intro_video, media_attributes: [:item])
  end
end
