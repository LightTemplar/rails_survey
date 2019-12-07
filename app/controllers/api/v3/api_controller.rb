# frozen_string_literal: true

class Api::V3::ApiController < ActionController::API
  before_action :restrict_access

  private

  def restrict_access
    api_key = ApiKey.where(access_token: params[:access_token])&.first
    head :unauthorized unless api_key
  end
end
