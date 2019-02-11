# frozen_string_literal: true

# == Schema Information
#
# Table name: multiple_skips
#
#  id                       :integer          not null, primary key
#  question_identifier      :string
#  option_identifier        :string
#  skip_question_identifier :string
#  instrument_question_id   :integer
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  value                    :string
#

class MultipleSkip < ActiveRecord::Base
  belongs_to :option, foreign_key: :option_identifier
  belongs_to :question, foreign_key: :question_identifier
  belongs_to :instrument_question, touch: true
  delegate :instrument, to: :instrument_question
  acts_as_paranoid
  validates :instrument_question_id, uniqueness: { scope:
    %i[question_identifier option_identifier skip_question_identifier] }

  def skip_to(op_id, multiple_skips)
    option = instrument_question.hashed_options[op_id]
    skipped = +''
    multiple_skips.each do |m_skip|
      q = instrument.instrument_questions.where(identifier: m_skip.skip_question_identifier).first
      skipped << "<b>##{q.number_in_instrument}</b>, "
    end
    if option
      index = instrument_question.non_special_options.index(option)
      "* If <b>(#{instrument_question.letters[index]})</b> skip questions: #{skipped.strip.chop}"
    else
      "* If <b>#{op_id}</b> skip questions: #{skipped.strip.chop}"
    end
  end
end
