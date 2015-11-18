class AndroidUpdatePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin?
        AndroidUpdate.all
      end
    end
  end
end