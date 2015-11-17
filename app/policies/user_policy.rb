class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin?
        User.all
      else
        User.joins(:projects).where('projects.id IN (?)', user.projects.pluck(:id)).distinct
      end
    end
  end

  def index?
    @user.admin_user?
  end

  def new?
    @user.admin_user?
  end

  def create?
    @user.admin_user?
  end

  def destroy?
    @user.super_admin?
  end

  def show?
    @user.admin_user?
  end

  def edit?
    @user.admin_user?
  end

  def update?
    @user.admin_user?
  end

end