# frozen_string_literal: true

module Api
  module V4
    class ApiController < ApplicationController
      skip_before_action :authenticate_user!
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user_from_token!

      private

      def authenticate_user_from_token!
        user_email = params[:user_email].presence
        user = user_email && User.find_by_email(user_email)
        if user && Devise.secure_compare(user.authentication_token, params[:authentication_token])
          sign_in user, store: false
        else
          render json: { success: false, info: 'Login failure' }, status: :unauthorized
        end
      end
    end
  end
end
