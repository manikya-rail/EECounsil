module Api
  module V1
    class BlogsController < ApplicationController
      before_action :blogs, only: :index

      def index
        render json: {blogs: ActiveModel::ArraySerializer.new(@blogs, each_serializer: BlogSerializer)}
      end

      def categories
        render json: Category.all
      end

      private
      def blogs
        @blogs = params[:category_id].present? ? Blog.where(category_id: params[:category_id]) : Blog.all
      end
    end
  end
end