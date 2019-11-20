# frozen_string_literal: true

# == Schema Information
#
# Table name: grid_label_translations
#
#  id                        :integer          not null, primary key
#  grid_label_id             :integer
#  instrument_translation_id :integer
#  label                     :text
#  created_at                :datetime
#  updated_at                :datetime
#

class GridLabelTranslation < ApplicationRecord
  belongs_to :grid_label, touch: true
  belongs_to :instrument_translation, touch: true
end
