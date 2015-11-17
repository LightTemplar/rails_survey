class DeviceSyncEntryPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    @user.admin_user? || @user.manager?
  end

  def show?
    @user.admin_user? || @user.manager?
  end
end