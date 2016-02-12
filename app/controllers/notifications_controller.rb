class NotificationsController < ApplicationController
  after_action :verify_authorized
  
  def index
    @dangerous_devices = current_project.non_responsive_devices
    @critical_surveys = current_project.surveys.where(has_critical_responses: true).order('created_at DESC')
    authorize @dangerous_devices
  end
  
end
