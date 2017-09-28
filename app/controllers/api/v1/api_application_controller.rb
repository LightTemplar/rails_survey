module Api
  module V1
    class ApiApplicationController < ApplicationController
      before_action :restrict_access
      before_action :check_version_code
      skip_before_action :authenticate_user!
      skip_before_action :authenticate_user_from_token!
      skip_before_action :set_project

      private

      def restrict_access
        unless current_user
          api_key = ApiKey.find_by_access_token(params[:access_token])
          head :unauthorized unless api_key
        end
      end

      def check_version_code
        if params[:version_code]
          head :upgrade_required unless params[:version_code].to_i >= Settings.minimum_android_version_code
        end
      end
    end
  end
end
