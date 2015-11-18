class ApiKeyPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin?
        ApiKey.all
      end
    end
  end
end