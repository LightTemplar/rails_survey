# frozen_string_literal: true

# == Schema Information
#
# Table name: next_questions
#
#  id                       :integer          not null, primary key
#  question_identifier      :string
#  option_identifier        :string
#  next_question_identifier :string
#  instrument_question_id   :integer
#  created_at               :datetime
#  updated_at               :datetime
#  deleted_at               :datetime
#  value                    :string
#  complete_survey          :boolean
#

class NextQuestion < ActiveRecord::Base
  belongs_to :option, foreign_key: :option_identifier
  belongs_to :question, foreign_key: :question_identifier
  belongs_to :instrument_question, touch: true
  delegate :instrument, to: :instrument_question
  acts_as_paranoid
  validates :instrument_question_id, uniqueness: { scope:
    %i[question_identifier option_identifier next_question_identifier] }

  def skip_to
    option = instrument_question.hashed_options[option_identifier]
    skip_to_question = instrument.instrument_questions.where(identifier: next_question_identifier).first
    if option
      index = instrument_question.non_special_options.index(option)
      "=> If <b>(#{instrument_question.letters[index]})</b> skip to <b>##{skip_to_question.number_in_instrument}</b>"
    else
      "=> If <b>#{option_identifier}</b> skip to <b>##{skip_to_question.number_in_instrument}</b>"
    end
  end
end
