# frozen_string_literal: true

# == Schema Information
#
# Table name: validation_translations
#
#  id            :integer          not null, primary key
#  validation_id :integer
#  language      :string
#  text          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ValidationTranslation < ApplicationRecord
  belongs_to :validation, touch: true
  validates :text, presence: true, allow_blank: false
  validates :language, presence: true, allow_blank: false
  validates :validation_id, presence: true, allow_blank: false
end
