# == Schema Information
#
# Table name: rules
#
#  id            :integer          not null, primary key
#  rule_type     :string
#  instrument_id :integer
#  rule_params   :string
#  created_at    :datetime
#  updated_at    :datetime
#  deleted_at    :time
#

class Rule < ActiveRecord::Base
  Rules = [:instrument_survey_limit_rule, :instrument_timing_rule, :instrument_survey_limit_per_minute_rule, :instrument_launch_rule, :participant_type_rule, :participant_age_rule].freeze
  belongs_to :instrument
  validates :rule_type, presence: true
  acts_as_paranoid

  def rule_params_hash
    JSON.parse(rule_params)
  end

  def self.rule_type_values(key)
    Rules.map { |rule| Settings.rule_types.send(rule).send(key) }
  end
end
