# frozen_string_literal: true

# == Schema Information
#
# Table name: subdomain_translations
#
#  id           :bigint           not null, primary key
#  language     :string
#  text         :string
#  subdomain_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class SubdomainTranslation < ApplicationRecord
  include Sanitizable
  belongs_to :subdomain, touch: true
  validates :text, presence: true, allow_blank: false
  validates :subdomain_id, presence: true, allow_blank: false
  validates :language, presence: true, allow_blank: false
end
