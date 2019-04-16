# frozen_string_literal: true

# == Schema Information
#
# Table name: option_set_translations
#
#  id                    :integer          not null, primary key
#  option_set_id         :integer
#  option_translation_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class OptionSetTranslation < ActiveRecord::Base
  belongs_to :option_set, touch: true
  belongs_to :option_translation
  validates :option_translation_id, uniqueness: { scope: :option_set_id }

  def option
    option_translation.option
  end

  def language
    option_translation.language
  end
end
