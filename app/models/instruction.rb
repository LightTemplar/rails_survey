# == Schema Information
#
# Table name: instructions
#
#  id         :integer          not null, primary key
#  title      :string
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#

class Instruction < ActiveRecord::Base
  has_many :questions
  has_many :instruction_translations
end
