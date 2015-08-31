# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Role < ActiveRecord::Base
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  validates_uniqueness_of :name 
end
