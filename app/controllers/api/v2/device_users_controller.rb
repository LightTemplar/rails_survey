# frozen_string_literal: true

module Api
  module V2
    class DeviceUsersController < Api::V2::ApiController
      respond_to :json

      def index
        @device_user = current_device_user
      end
    end
  end
end
