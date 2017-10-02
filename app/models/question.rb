# == Schema Information
#
# Table name: questions
#
#  id                               :integer          not null, primary key
#  text                             :text
#  question_type                    :string(255)
#  question_identifier              :string(255)
#  instrument_id                    :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  following_up_question_identifier :string(255)
#  reg_ex_validation                :string(255)
#  number_in_instrument             :integer
#  reg_ex_validation_message        :string(255)
#  deleted_at                       :datetime
#  follow_up_position               :integer          default(0)
#  identifies_survey                :boolean          default(FALSE)
#  instructions                     :text             default("")
#  child_update_count               :integer          default(0)
#  grid_id                          :integer
#  instrument_version_number        :integer          default(-1)
#  section_id                       :integer
#  critical                         :boolean
#  number_in_grid                   :integer
#  question_set_id                  :integer
#  option_set_id                    :integer
#

class Question < ActiveRecord::Base
  include Translatable
  default_scope { order('number_in_instrument ASC') }
  belongs_to :instrument
  belongs_to :grid
  belongs_to :section
  belongs_to :option_set
  belongs_to :question_set
  has_many :responses
  has_many :options, dependent: :destroy
  has_many :translations, foreign_key: 'question_id', class_name: 'QuestionTranslation', dependent: :destroy
  has_many :images, dependent: :destroy
  # different from has_many :skips, through: :options
  has_many :option_skips, through: :options, source: :skips
  has_many :skips, foreign_key: :question_identifier, primary_key: :question_identifier, dependent: :destroy
  has_many :question_randomized_factors, dependent: :destroy
  delegate :project, to: :instrument
  before_save :update_instrument_version, if: proc { |question| question.changed? && !question.child_update_count_changed? }
  before_save :update_question_translation, if: proc { |question| question.text_changed? }
  after_save :record_instrument_version
  before_destroy :update_instrument_version
  after_update :update_dependent_records
  after_create :create_special_options
  has_paper_trail
  acts_as_paranoid

  validates :question_identifier, uniqueness: true, presence: true, allow_blank: false
  validates :text, presence: true, allow_blank: false
  validates :number_in_instrument, presence: true, allow_blank: false

  amoeba do
    enable
    include_association :options
    include_association :translations
    nullify :instrument_id
    nullify :number_in_instrument
    nullify :question_identifier
    nullify :following_up_question_identifier
    set follow_up_position: 0
  end

  def create_special_options(special_options = instrument.special_options)
    skip_option_callbacks
    unless special_options.blank?
      special_options.reject { |opt_text| opt_text == Settings.skipped_question_special_response }.each do |option_text|
        create_special_option(option_text)
      end
    end
    if Settings.question_without_options.include?(question_type)
      create_special_option(Settings.any_default_non_empty_response)
    end
    set_option_callbacks
    update_columns(child_update_count: option_count)
  end

  def options?
    !options.empty?
  end

  def option_count
    options.size
  end

  def non_special_options
    options.reject(&:special)
  end

  def non_special_options?
    !non_special_options.empty?
  end

  def image_count
    images.size
  end

  def instrument_version
    if instrument && (read_attribute(:instrument_version_number).nil? || read_attribute(:instrument_version_number) == -1)
      instrument.current_version_number
    else
      read_attribute(:instrument_version_number)
    end
  end

  def other?
    Settings.question_with_other.include? question_type
  end

  def other_index
    non_special_options.length
  end

  def update_question_translation(status = true)
    translations.each do |translation|
      translation.update_attribute(:question_changed, status)
    end
  end

  def update_question_version
    # Force update for paper trail
    increment!(:child_update_count)
  end

  def question_version
    versions.size
  end

  def starts_section?
    section && !section.questions.blank? ? section.questions.first == self : false
  end

  def select_one_variant?
    %w[SELECT_ONE SELECT_ONE_WRITE_OTHER].include? question_type
  end

  def select_multiple_variant?
    %w[SELECT_MULTIPLE SELECT_MULTIPLE_WRITE_OTHER].include? question_type
  end

  def list_of_boxes_variant?
    %(LIST_OF_TEXT_BOXES LIST_OF_INTEGER_BOXES).include? question_type
  end

  def slider_variant?
    %(SLIDER LABELED_SLIDER).include? question_type
  end

  def grid_labels
    grid.grid_labels if grid
  end

  def grid_labels?
    !grid_labels.blank?
  end

  def optionable?
    return grid_labels? if grid
    options?
  end

  private

  def update_instrument_version
    instrument.update_instrument_version unless instrument.nil?
  end

  def record_instrument_version
    update_column(:instrument_version_number, instrument_version)
  end

  def update_dependent_records
    if question_identifier_was && question_identifier != question_identifier_was
      skips_to_update = Skip.where(question_identifier: question_identifier_was)
      skips_to_update.update_all(question_identifier: question_identifier) unless skips_to_update.blank?
      options_to_update = Option.where(next_question: question_identifier_was)
      options_to_update.update_all(next_question: question_identifier) unless options_to_update.blank?
      follow_ups_to_update = Question.where(following_up_question_identifier: question_identifier_was)
      follow_ups_to_update.update_all(following_up_question_identifier: question_identifier) unless follow_ups_to_update.blank?
    end
  end

  def create_special_option(option_text)
    options.create(text: option_text, special: true, number_in_question: options.size + 1) if options.where(text: option_text).blank?
  end

  def skip_option_callbacks
    Option.skip_callback(:save, :after, :record_instrument_version_number)
    Option.skip_callback(:save, :before, :update_instrument_version)
    Option.skip_callback(:save, :before, :update_option_translation)
  end

  def set_option_callbacks
    Option.set_callback(:save, :after, :record_instrument_version_number)
    Option.set_callback(:save, :before, :update_instrument_version)
    Option.set_callback(:save, :before, :update_option_translation)
  end
end
