# frozen_string_literal: true

# == Schema Information
#
# Table name: condition_skips
#
#  id                            :integer          not null, primary key
#  instrument_question_id        :integer
#  question_identifier           :string
#  condition_question_identifier :string
#  condition_option_identifier   :string
#  option_identifier             :string
#  condition                     :string
#  next_question_identifier      :string
#  deleted_at                    :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class ConditionSkip < ApplicationRecord
  belongs_to :instrument_question, touch: true
  acts_as_paranoid
end
