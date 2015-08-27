class DevicesController < ApplicationController
  after_action :verify_authorized

  def index
    @devices = current_project.devices.includes(:device_sync_entries).order('device_sync_entries.updated_at DESC')
    authorize @devices
  end

  def show
    @device = current_project.devices.find(params[:id])
    authorize @device
  end

end