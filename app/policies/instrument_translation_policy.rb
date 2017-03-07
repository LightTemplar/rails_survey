class InstrumentTranslationPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def new?
    write_access
  end

  def new_gt?
    write_access
  end

  def create?
    write_access
  end

  def destroy?
    @user.admin_user?
  end

  def show?
    true
  end

  def show_original?
    true
  end

  def edit?
    write_access
  end

  def update?
    write_access
  end

  private

  def write_access
    @user.admin_user? || @user.translator?
  end
end
