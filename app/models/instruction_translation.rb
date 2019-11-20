# frozen_string_literal: true

# == Schema Information
#
# Table name: instruction_translations
#
#  id             :integer          not null, primary key
#  instruction_id :integer
#  language       :string
#  text           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class InstructionTranslation < ApplicationRecord
  belongs_to :instruction, touch: true
  validates :text, presence: true, allow_blank: false
  validates :language, presence: true, allow_blank: false
  validates :instruction_id, presence: true, allow_blank: false
end
