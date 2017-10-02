# == Schema Information
#
# Table name: option_sets
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

class OptionSet < ActiveRecord::Base
  has_many :options
  has_many :questions
end
