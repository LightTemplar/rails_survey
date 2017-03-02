# == Schema Information
#
# Table name: options
#
#  id                        :integer          not null, primary key
#  question_id               :integer
#  text                      :text
#  created_at                :datetime
#  updated_at                :datetime
#  next_question             :string(255)
#  number_in_question        :integer
#  deleted_at                :datetime
#  instrument_version_number :integer          default(-1)
#  special                   :boolean          default(FALSE)
#  critical                  :boolean
#

class Option < ActiveRecord::Base
  include CacheWarmAble
  include Translatable
  default_scope { order('special ASC, number_in_question ASC') }
  scope :special_options, -> { where(special: true) }
  belongs_to :question
  delegate :instrument, to: :question, allow_nil: true
  delegate :project, to: :question
  has_many :translations, foreign_key: 'option_id', class_name: 'OptionTranslation', dependent: :destroy
  before_save :update_instrument_version, if: proc { |option| option.changed? }
  before_save :update_option_translation, if: proc { |option| option.text_changed? }
  before_destroy :update_instrument_version
  after_save :record_instrument_version_number
  after_save :sanitize_next_question
  after_save :check_parent_criticality
  has_paper_trail
  acts_as_paranoid
  has_many :skips, dependent: :destroy
  has_one :grid_label

  validates :text, presence: true, allow_blank: false

  amoeba do
    enable
    include_field :translations
    nullify :next_question
  end

  def sanitize_next_question
    unless next_question.blank?
      next_qst = instrument.questions.where(question_identifier: next_question)
      update_columns(next_question: nil) if next_qst.blank?
    end
  end

  def to_s
    text
  end

  # Return grid_label text if option has grid_label
  def text
    if grid_label
      grid_label.label
    else
      read_attribute(:text)
    end
  end

  def instrument_version
    if instrument && (read_attribute(:instrument_version_number) == -1)
      instrument.current_version_number
    else
      read_attribute(:instrument_version_number)
    end
  end

  # def as_json(options={})
  #   Rails.cache.fetch("#{cache_key}/as_json") do
  #     super((options || {}).merge({methods: [:instrument_version]}))
  #   end
  # end

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

  def check_parent_criticality
    update_columns(critical: nil) if critical && !question.critical
  end
end
