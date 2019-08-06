# frozen_string_literal: true

module Api
  module V4
    class SessionsController < Devise::SessionsController
      skip_before_filter :verify_authenticity_token, if: proc { |c| c.request.format == 'application/json' }
      skip_before_filter :verify_signed_out_user, only: :destroy, if: proc { |c| c.request.format == 'application/json' }

      respond_to :json

      def create
        warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
        if current_user
          render json: { success: true, info: 'Logged in', authentication_token: current_user.authentication_token }, status: :ok
        else
          failure
        end
      end

      def destroy
        current_user = User.find_by_authentication_token(params[:authentication_token])
        if current_user
          current_user.update_column(:authentication_token, nil)
          render json: { success: true, info: 'Logged out' }, status: :ok
        else
          failure
        end
      end

      def failure
        render json: { success: false, info: 'Login failure' }, status: :unauthorized
      end
    end
  end
end
