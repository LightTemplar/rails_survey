# frozen_string_literal: true

# == Schema Information
#
# Table name: score_scheme_centers
#
#  id              :bigint           not null, primary key
#  center_id       :integer
#  score_scheme_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ScoreSchemeCenter < ApplicationRecord
  belongs_to :center
  belongs_to :score_scheme
  validates :center_id, presence: true, allow_blank: false
  validates :score_scheme_id, presence: true, allow_blank: false
end
