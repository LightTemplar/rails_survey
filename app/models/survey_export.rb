# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_exports
#
#  id               :bigint           not null, primary key
#  survey_id        :integer
#  long             :text
#  short            :text
#  wide             :text
#  last_response_at :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SurveyExport < ApplicationRecord
  belongs_to :survey
end
