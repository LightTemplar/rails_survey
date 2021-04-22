# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_notes
#
#  id             :bigint           not null, primary key
#  uuid           :string
#  survey_uuid    :string
#  device_user_id :integer
#  reference      :string
#  text           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class SurveyNote < ApplicationRecord
  attribute :uuid, :string, default: -> { SecureRandom.uuid }
  belongs_to :survey, foreign_key: :survey_uuid, primary_key: :uuid
  belongs_to :device_user
end
