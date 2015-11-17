class NotificationPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    @user.admin_user? || @user.manager? || @user.user?
  end
  
end