class ApplicationController < ActionController::Base
  include SessionsHelper
  include ProjectsHelper
  include Pundit
  protect_from_forgery with: :exception
  before_filter :authenticate_user_from_token!
  before_filter :store_location
  before_filter :authenticate_user!
  before_filter :set_project
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def after_sign_in_path_for(_resource_or_scope)
    set_current_project_id(session[:previous_url])
    session[:previous_url] || root_path
  end

  def after_update_path_for(_resource)
    session[:previous_url] || root_path
  end

  def respond_to_ajax
    if request.xhr?
      respond_to do |format|
        format.js
      end
    end
  end

  def authenticate_active_admin_user!
    authenticate_user!
    unless current_user.admin_user?
      flash[:alert] = 'Unauthorized Access!'
      redirect_to root_path
    end
  end

  private

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user = user_email && User.find_by_email(user_email)

    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      sign_in user, store: false
    end
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    flash.keep
    request_path = request.fullpath.split('/')
    if request_path[1] == 'api'
      redirect_to request.referrer, status: 303
    elsif request.fullpath == root_path || request.fullpath == '/users/sign_in'
      redirect_to request_roles_path
    else
      redirect_to (request.referrer || root_path)
    end
  end

  def set_project
    if params[:project_id] && current_project && current_project.id != params[:project_id]
      project = Project.find(params[:project_id])
      set_current_project(project)
    end
  end
end
