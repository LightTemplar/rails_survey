# frozen_string_literal: true

# == Schema Information
#
# Table name: back_translations
#
#  id                    :integer          not null, primary key
#  text                  :text
#  language              :string
#  backtranslatable_id   :integer
#  backtranslatable_type :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  approved              :boolean
#

class BackTranslation < ApplicationRecord
  belongs_to :backtranslatable, polymorphic: true
end
