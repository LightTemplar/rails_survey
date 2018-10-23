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
#

class BackTranslation < ActiveRecord::Base
  belongs_to :backtranslatable, polymorphic: true
end
