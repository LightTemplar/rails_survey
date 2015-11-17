class DevicePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    viewers
  end

  def show?
    viewers
  end

  private
  def viewers
    @user.admin_user? || @user.manager? || @user.user?
  end

end