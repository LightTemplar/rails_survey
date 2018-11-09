# == Schema Information
#
# Table name: display_instructions
#
#  id                     :integer          not null, primary key
#  display_id             :integer
#  instruction_id         :integer
#  position               :integer
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  instrument_question_id :integer
#

class DisplayInstruction < ActiveRecord::Base
  belongs_to :display, touch: true
  belongs_to :instruction
  belongs_to :instrument_question
  acts_as_paranoid
  after_save :update_position
  delegate :instrument, to: :display

  private
  def update_position
    update_columns(position: instrument_question.number_in_instrument) if instrument_question
  end
end