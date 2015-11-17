class InstrumentPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    read_access
  end
  
  def new?
    write_access
  end
  
  def create?
    write_access
  end

  def destroy?
    write_access
  end

  def show?
    read_access
  end

  def edit?
    write_access
  end

  def update?
    write_access
  end
  
  def csv_export?
    export_access 
  end

  def pdf_export?
    export_access
  end
  
  def export_responses?
    export_access
  end
  
  def export_pictures?
    export_access 
  end
  
  def move?
    read_access
  end
  
  def update_move?
    write_access
  end

  def copy?
    read_access
  end

  def update_copy?
    write_access
  end

  def copy_questions?
    write_access
  end
  
  private
  def read_access
    true
  end
  
  def write_access
    @user.admin_user? || @user.manager?
  end
  
  def export_access
    @user.admin_user? || @user.manager? || @user.analyst?
  end
end