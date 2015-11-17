class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def new?
    create?
  end

  def create?
    @user.admin_user?
  end

  def edit?
    update?
  end

  def update?
    @user.admin_user?
  end

  def destroy?
    @user.admin_user?
  end

  def destroy_all?
    @user.admin_user?
  end

end