# == Schema Information
#
# Table name: sections
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  start_question_identifier :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  instrument_id             :integer
#  deleted_at                :datetime
#

class Section < ActiveRecord::Base
  include Translatable
  belongs_to :instrument
  belongs_to :question, foreign_key: :start_question_identifier, primary_key: :question_identifier
  has_many :translations, foreign_key: 'section_id', class_name: 'SectionTranslation', dependent: :destroy
  before_save :update_instrument_version, if: Proc.new { |section| section.changed? }
  before_save :update_section_translation, if: Proc.new { |section| section.title_changed? }
  before_destroy :update_instrument_version
  acts_as_paranoid 
  validates :title, presence: true
  validates :start_question_identifier, presence: true
  validate :question_identifier_exists
  
  def update_section_translation(status = true)
    translations.each do |translation|
      translation.update_attribute(:section_changed, status)
    end
  end
  
  private
  def update_instrument_version
    instrument.update_instrument_version
  end

  def question_identifier_exists
    unless Question.find_by_question_identifier(start_question_identifier)
      errors.add(:question, ': question does not exist!')
    end
  end
  
end
