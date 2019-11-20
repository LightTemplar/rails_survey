# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit
  before_action :authenticate_user_from_token!
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user = user_email && User.find_by_email(user_email)

    sign_in user, store: false if user && Devise.secure_compare(user.authentication_token, params[:user_token])
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    flash.keep
    request_path = request.fullpath.split('/')
    if request_path[1] == 'api'
      redirect_to request.referrer, status: 303
    elsif request.fullpath == root_path || request.fullpath == user_session_path
      redirect_to request_roles_path
    else
      redirect_to (request.referrer || root_path)
    end
  end
end
