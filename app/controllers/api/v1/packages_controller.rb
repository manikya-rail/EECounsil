module Api
  module V1
    class Api::V1::PackagesController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken

      def index
        @packages = Package.all.order(created_at: 'asc')
        render json: @packages
      end

    end
  end
end
