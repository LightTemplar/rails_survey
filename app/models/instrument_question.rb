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
#

class InstrumentQuestion < ActiveRecord::Base
  belongs_to :instrument, touch: true
  belongs_to :question
  belongs_to :display, touch: true
  has_many :next_questions
  has_many :multiple_skips
  has_many :follow_up_questions
  has_many :translations, through: :question
  acts_as_paranoid
  has_paper_trail
  validates :identifier, presence: true
  validates :identifier, uniqueness: { scope: :instrument_id,
    message: 'instrument already has this identifier' }

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
end
