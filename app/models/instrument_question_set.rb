# == Schema Information
#
# Table name: instrument_question_sets
#
#  id              :integer          not null, primary key
#  instrument_id   :integer
#  question_set_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class InstrumentQuestionSet < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :question_set
  has_many :questions, through: :question_set
  has_many :options, through: :questions
  after_create :initialize_instrument_questions
  before_destroy :destroy_instrument_questions

  private

  def initialize_instrument_questions
    questions_size = instrument.instrument_questions.size
    questions.each do |question|
      questions_size += 1
      display = Display.create!(
        mode: Settings.display_types.first,
        position:  questions_size,
        instrument_id: instrument.id
      )
      InstrumentQuestion.create!(
        question_id: question.id,
        instrument_id: instrument.id,
        number_in_instrument: questions_size,
        display_id: display.id
      )
    end
  end

  def destroy_instrument_questions
    instrument.instrument_questions.destroy_all
  end
end
