# frozen_string_literal: true

# == Schema Information
#
# Table name: raw_scores
#
#  id                :integer          not null, primary key
#  score_unit_id     :integer
#  survey_score_id   :integer
#  value             :float
#  created_at        :datetime
#  updated_at        :datetime
#  uuid              :string
#  survey_score_uuid :string
#  deleted_at        :datetime
#

class RawScore < ApplicationRecord
  belongs_to :score_unit
  belongs_to :survey_score

  acts_as_paranoid
end
