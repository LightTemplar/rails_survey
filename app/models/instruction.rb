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
  has_many :option_sets, dependent: :nullify
  has_many :instrument_questions, through: :questions
  has_many :instruction_translations, dependent: :destroy
  has_many :display_instructions, dependent: :destroy
  acts_as_paranoid
  has_paper_trail
  after_touch :touch_instrument_questions, :touch_display_instructions, :touch_instrument
  after_commit :touch_instrument_questions, :touch_display_instructions, :touch_instrument

  def instruments
    instrument_questions.map(&:instrument) | display_instructions.map(&:instrument)
  end

  private
  def touch_instrument_questions
    instrument_questions.update_all(updated_at: Time.now)
  end

  def touch_display_instructions
    display_instructions.update_all(updated_at: Time.now)
  end

  def touch_instrument
    instruments.map(&:touch)
  end

end
