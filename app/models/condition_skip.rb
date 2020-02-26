# frozen_string_literal: true

# == Schema Information
#
# Table name: condition_skips
#
#  id                       :integer          not null, primary key
#  instrument_question_id   :integer
#  question_identifier      :string
#  next_question_identifier :string
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  question_identifiers     :text
#  option_ids               :text
#  values                   :text
#  value_operators          :text
#

class ConditionSkip < ApplicationRecord
  belongs_to :instrument_question, touch: true
  acts_as_paranoid
  validates :instrument_question_id, uniqueness: { scope:
    %i[question_identifiers option_ids values value_operators] }
end
