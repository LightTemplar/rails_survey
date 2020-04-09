# frozen_string_literal: true

# == Schema Information
#
# Table name: centers
#
#  id              :bigint           not null, primary key
#  score_scheme_id :integer
#  identifier      :string
#  name            :string
#  center_type     :string
#  administration  :string
#  region          :string
#  department      :string
#  municipality    :string
#  score_data      :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Center < ApplicationRecord
  belongs_to :score_scheme
  has_many :survey_scores, foreign_key: :identifier, primary_key: :identifier

  validates :score_scheme_id, presence: true, allow_blank: false
  validates :identifier, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false
  validates :center_type, presence: true, allow_blank: false
end
