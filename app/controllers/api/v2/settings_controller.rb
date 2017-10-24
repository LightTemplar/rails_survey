module Api
  module V2
      class SettingsController < ApiApplicationController
        respond_to :json

        def index
          respond_with Settings
        end
      end
    end
  end
