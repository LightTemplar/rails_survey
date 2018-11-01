# == Schema Information
#
# Table name: instrument_questions
#
#  id                   :integer          not null, primary key
#  question_id          :integer
#  instrument_id        :integer
#  number_in_instrument :integer
#  display_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#  identifier           :string
#  deleted_at           :datetime
#  table_identifier     :string
#

class InstrumentQuestion < ActiveRecord::Base
  belongs_to :instrument, touch: true
  belongs_to :question
  belongs_to :display, touch: true
  has_many :next_questions, dependent: :destroy
  has_many :multiple_skips, dependent: :destroy
  has_many :follow_up_questions, dependent: :destroy
  has_many :condition_skips, dependent: :destroy
  has_many :translations, through: :question
  has_many :display_instructions, dependent: :destroy
  has_many :loop_questions, dependent: :destroy
  acts_as_paranoid
  has_paper_trail
  validates :identifier, presence: true
  validates :identifier, uniqueness: { scope: :instrument_id,
    message: 'instrument already has this identifier' }
  after_update :update_display_instructions, if: :number_in_instrument_changed?
  after_destroy :renumber_questions

  def options
    option_set_ids = [question.option_set_id, question.special_option_set_id].compact
    option_ids = OptionInOptionSet.where(option_set_id: option_set_ids).pluck(:option_id).uniq
    Option.where(id: option_ids)
  end

  def copy(display_id, instrument_id)
    iq_copy = self.dup
    iq_copy.display_id = display_id
    iq_copy.instrument_id = instrument_id
    i = Instrument.find instrument_id
    iq_copy.number_in_instrument = i.instrument_questions.size + 1
    iq_copy.save!
    next_questions.each do |nq|
      nq_copy = nq.dup
      nq_copy.instrument_question_id = iq_copy.id
      nq_copy.save!
    end
    multiple_skips.each do |ms|
      ms_copy = ms.dup
      ms_copy.instrument_question_id = iq_copy.id
      ms_copy.save!
    end
    follow_up_questions.each do |fuq|
      fuq_copy = fuq.dup
      fuq_copy.instrument_question_id = iq_copy.id
      fuq_copy.save!
    end
  end

  private
  def update_display_instructions
    display_instructions.update_all(position: number_in_instrument)
  end

  def renumber_questions
    instrument.renumber_questions
  end
end
