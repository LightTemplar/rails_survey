class ProjectPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin?
        Project.all
      else
        user.projects
      end
    end
  end

  def index?
    true
  end

  def new?
    create?
  end

  def create?
    @user.super_admin?
  end

  def destroy?
    @user.super_admin?
  end

  def show?
    true
  end

  def edit?
    @user.admin_user?
  end

  def update?
    @user.admin_user?
  end

  def export?
    @user.admin_user? || @user.analyst?
  end

  def question_sets
    true
  end
end
