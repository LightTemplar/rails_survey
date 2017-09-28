class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  def privacy; end
end
