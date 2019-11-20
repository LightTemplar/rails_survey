# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  validates_uniqueness_of :name
end
