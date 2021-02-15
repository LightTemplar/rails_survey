# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_translations
#
#  id         :bigint           not null, primary key
#  language   :string
#  text       :string
#  domain_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DomainTranslation < ApplicationRecord
  include Sanitizable
  belongs_to :domain, touch: true
  validates :text, presence: true, allow_blank: false
  validates :domain_id, presence: true, allow_blank: false
  validates :language, presence: true, allow_blank: false
end
