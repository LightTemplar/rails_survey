# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    @user&.admin_user?
  end

  def show?
    index?
  end

  def new?
    create?
  end

  def create?
    @user&.admin_user?
  end

  def edit?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def destroy_all?
    create?
  end
end
