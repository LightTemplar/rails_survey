# frozen_string_literal: true

# == Schema Information
#
# Table name: validations
#
#  id                  :integer          not null, primary key
#  title               :string
#  validation_text     :string
#  validation_message  :string
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  validation_type     :string
#  response_identifier :string
#  relational_operator :string
#

class Validation < ApplicationRecord
  has_many :questions, dependent: :nullify
  has_many :validation_translations, dependent: :destroy
  acts_as_paranoid
end
