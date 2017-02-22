class SurveyPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    @user.admin_user? || @user.manager? || @user.user? || @user.analyst?
  end

  def instrument_surveys?
    @user.admin_user? || @user.manager? || @user.user? || @user.analyst?
  end

  def identifier_surveys?
    @user.admin_user? || @user.manager? || @user.user? || @user.analyst?
  end

  def destroy?
    @user.admin_user?
  end

  def show?
    @user.admin_user? || @user.manager? || @user.analyst?
  end
end
