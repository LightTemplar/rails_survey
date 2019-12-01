# frozen_string_literal: true

class Api::V4::ApiController < ActionController::API
  include Knock::Authenticable
  undef_method :current_user
  before_action :authenticate_user
end
