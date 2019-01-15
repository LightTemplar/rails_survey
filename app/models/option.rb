# == Schema Information
#
# Table name: options
#
#  id                        :integer          not null, primary key
#  text                      :text
#  created_at                :datetime
#  updated_at                :datetime
#  deleted_at                :datetime
#  instrument_version_number :integer          default(-1)
#  identifier                :string
#

class Option < ActiveRecord::Base
  include Translatable
  has_many :option_in_option_sets, dependent: :destroy
  has_many :option_sets, through: :option_in_option_sets
  has_many :translations, foreign_key: 'option_id', class_name: 'OptionTranslation', dependent: :destroy
  has_many :skip_patterns, foreign_key: 'option_identifier', dependent: :destroy
  has_paper_trail
  acts_as_paranoid

  validates :text, presence: true, allow_blank: false
  validates :identifier, presence: true, uniqueness: true

  amoeba do
    enable
    include_association :translations
  end

  def to_option_in_option_set
    OptionInOptionSet.create!(option_id: id, option_set_id: option_set_id,
      number_in_question: number_in_question) if id && option_set_id && number_in_question
  end

  def to_s
    text
  end

# TODO: Doesn't work anymore
  def instrument_version
    if instrument && (read_attribute(:instrument_version_number) == -1)
      instrument.current_version_number
    else
      read_attribute(:instrument_version_number)
    end
  end

  def update_option_translation(status = true)
    translations.each do |translation|
      translation.update_attribute(:option_changed, status)
    end
  end

  private

  def update_instrument_version
    unless instrument.nil? && question.nil?
      instrument.update_instrument_version
      question.update_question_version
      question.update_column(:instrument_version_number, instrument.current_version_number)
    end
  end

  def record_instrument_version_number
    update_column(:instrument_version_number, instrument.current_version_number)
    question.update_column(:instrument_version_number, instrument.current_version_number)
  end

end
