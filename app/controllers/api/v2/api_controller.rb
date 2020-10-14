# frozen_string_literal: true

class Api::V2::ApiController < ActionController::API
  include Knock::Authenticable
  before_action :authenticate_device_user
end
