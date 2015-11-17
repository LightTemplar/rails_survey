class ResponseExportPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def new?
    download_privileges
  end
  
  def create?
    download_privileges
  end
  
  def update?
    download_privileges
  end
  
  def edit?
    download_privileges
  end
  
  def destroy?
    @user.admin_user?
  end
  
  def project_long_format_responses?
    download_privileges
  end

  def project_wide_format_responses?
    download_privileges
  end
    
  def instrument_long_format_responses?
    download_privileges
  end
  
  def instrument_wide_format_responses?
    download_privileges
  end
  
  def project_response_images?
    download_privileges
  end
  
  def instrument_response_images?
    download_privileges
  end
  
  private
  def download_privileges
    @user.admin_user? || @user.manager? || @user.analyst?
  end
  
end 