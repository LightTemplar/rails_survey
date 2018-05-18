# == Schema Information
#
# Table name: instructions
#
#  id         :integer          not null, primary key
#  title      :string
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class Instruction < ActiveRecord::Base
  has_many :questions, dependent: :nullify
  has_many :instruction_translations, dependent: :destroy
  has_many :display_instructions, dependent: :destroy
  acts_as_paranoid
  has_paper_trail
end
