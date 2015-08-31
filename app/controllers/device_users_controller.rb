class DeviceUsersController < ApplicationController
  def index
    @device_users = current_project.device_users
    authorize @device_users
  end

  def show
    @device_user = current_project.device_users.find(params[:id])
    authorize @device_user
  end

  def new
    @device_user = current_project.device_users.new
    authorize @device_user
  end

  def edit
    @device_user = current_project.device_users.find(params[:id])
    authorize @device_user
  end

  def create
    @device_user = current_project.device_users.new(device_user_params)
    authorize @device_user
    if @device_user.save && @device_user.project_device_users.create(device_user_id: @device_user.id, project_id: current_project.id)
      redirect_to project_device_users_path(current_project), notice: 'Device User was successfully created.'
    else
      render :new
    end
  end

  def update
    @device_user = current_project.device_users.find(params[:id])
    authorize @device_user
    if @device_user.update(device_user_params)
      redirect_to project_device_users_path(current_project), notice: 'Device User was successfully updated.'
    else
      render :edit
    end
  end

  private
  def device_user_params
    params.require(:device_user).permit(:name, :username, :password, :password_confirmation, :active, :device_ids, :project_ids)
  end

end