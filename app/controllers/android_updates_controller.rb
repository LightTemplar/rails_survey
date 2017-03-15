class AndroidUpdatesController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @update = AndroidUpdate.latest_version
  end

  def show
    apk = AndroidUpdate.find(params[:id])
    send_file apk.apk_update.path
  end
end
