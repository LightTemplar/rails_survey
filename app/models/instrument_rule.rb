# frozen_string_literal: true

# == Schema Information
#
# Table name: instrument_rules
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  rule_id       :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class InstrumentRule < ApplicationRecord
  belongs_to :instrument, touch: true
  belongs_to :rule
  acts_as_paranoid
  validates :instrument_id, presence: true
  validates :rule_id, presence: true
  validates :rule_id, uniqueness: { scope: :instrument_id,
                                    message: 'instrument already has this rule' }
end
