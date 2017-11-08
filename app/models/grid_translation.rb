# == Schema Information
#
# Table name: grid_translations
#
#  id                        :integer          not null, primary key
#  grid_id                   :integer
#  instrument_translation_id :integer
#  name                      :string
#  instructions              :text
#  created_at                :datetime
#  updated_at                :datetime
#

class GridTranslation < ActiveRecord::Base
  belongs_to :grid, touch: true
  belongs_to :instrument_translation, touch: true
end
