# == Schema Information
#
# Table name: critical_responses
#
#  id                  :integer          not null, primary key
#  question_identifier :string
#  option_identifier   :string
#  instruction_id      :integer
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class CriticalResponse < ActiveRecord::Base
  belongs_to :question, foreign_key: :question_identifier, primary_key: :question_identifier, touch: true
  belongs_to :option, foreign_key: :option_identifier, primary_key: :identifier
  belongs_to :instruction
  acts_as_paranoid
end
