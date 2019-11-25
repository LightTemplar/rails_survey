# frozen_string_literal: true

module Api
  module V4
    class ApiController < ActionController::API
      include Knock::Authenticable
      undef_method :current_user
      before_action :authenticate_user
    end
  end
end
