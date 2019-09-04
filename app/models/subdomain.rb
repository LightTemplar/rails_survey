# frozen_string_literal: true

# == Schema Information
#
# Table name: subdomains
#
#  id         :integer          not null, primary key
#  title      :string
#  domain_id  :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subdomain < ActiveRecord::Base
  belongs_to :domain
  has_many :score_units, dependent: :destroy

  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:domain_id] }
end
