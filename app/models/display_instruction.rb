# == Schema Information
#
# Table name: display_instructions
#
#  id             :integer          not null, primary key
#  display_id     :integer
#  instruction_id :integer
#  position       :integer
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class DisplayInstruction < ActiveRecord::Base
  belongs_to :display, touch: true
  belongs_to :instruction
  acts_as_paranoid
end
