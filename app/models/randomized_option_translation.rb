# == Schema Information
#
# Table name: randomized_option_translations
#
#  id                        :integer          not null, primary key
#  instrument_translation_id :integer
#  randomized_option_id      :integer
#  text                      :text
#  language                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class RandomizedOptionTranslation < ActiveRecord::Base
  belongs_to :instrument_translation
  belongs_to :randomized_option
end
