# frozen_string_literal: true

# == Schema Information
#
# Table name: domains
#
#  id              :integer          not null, primary key
#  title           :string
#  score_scheme_id :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  weight          :float
#

class Domain < ApplicationRecord
  belongs_to :score_scheme
  has_many :subdomains, dependent: :destroy
  has_many :raw_scores, through: :subdomains

  acts_as_paranoid

  validates :title, presence: true, allow_blank: false, uniqueness: { scope: [:score_scheme_id] }

  default_scope { order(:title) }
end
