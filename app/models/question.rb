# == Schema Information
#
# Table name: questions
#
#  id                    :integer          not null, primary key
#  text                  :text
#  question_type         :string
#  question_identifier   :string
#  created_at            :datetime
#  updated_at            :datetime
#  deleted_at            :datetime
#  identifies_survey     :boolean          default(FALSE)
#  critical              :boolean
#  question_set_id       :integer
#  option_set_id         :integer
#  instruction_id        :integer
#  special_option_set_id :integer
#  parent_identifier     :string
#  folder_id             :integer
#  validation_id         :integer
#  rank_responses        :boolean          default(FALSE)
#

class Question < ActiveRecord::Base
  include Translatable
  belongs_to :option_set
  belongs_to :special_option_set, class_name: 'OptionSet'
  belongs_to :question_set
  belongs_to :instruction
  belongs_to :folder
  belongs_to :validation
  has_many :options, through: :option_set
  has_many :responses
  has_many :translations, foreign_key: 'question_id', class_name: 'QuestionTranslation', dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :question_randomized_factors, dependent: :destroy
  has_many :instrument_questions, dependent: :destroy
  has_many :instruments, -> { distinct }, through: :instrument_questions
  has_many :skip_patterns, foreign_key: 'question_identifier', primary_key: 'question_identifier', dependent: :destroy
  before_save :update_question_translation, if: proc { |question| question.text_changed? }
  after_save :touch_instrument_questions
  after_commit :update_instruments_versions, on: %i[update destroy]
  has_paper_trail
  acts_as_paranoid
  validates :question_identifier, uniqueness: true, presence: true, allow_blank: false
  validates :text, presence: true, allow_blank: false

  def copy
    new_copy = dup
    new_copy.question_identifier = "#{question_identifier}_#{Time.now.to_i}"
    new_copy.parent_identifier = question_identifier
    new_copy.save!
    translations.each do |t|
      new_t = t.dup
      new_t.question_id = new_copy.id
      new_t.save!
    end
    new_copy
  end

  def options?
    !options.empty?
  end

  def option_count
    options.size
  end

  def image_count
    images.size
  end

  def other?
    Settings.question_with_other.include? question_type
  end

  def other_index
    options.length
  end

  def update_question_translation(status = true)
    translations.each do |translation|
      translation.update_attribute(:question_changed, status)
    end
  end

  def question_version
    versions.size
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

  private

  def touch_instrument_questions
    instrument_questions.update_all(updated_at: Time.now)
  end

  def update_instruments_versions
    instruments.each(&:touch)
  end
end
