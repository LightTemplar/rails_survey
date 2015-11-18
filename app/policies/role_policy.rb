class RolePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin?
        Role.all
      end
    end
  end
end