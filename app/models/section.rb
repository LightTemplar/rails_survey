# == Schema Information
#
# Table name: sections
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  instrument_id :integer
#  deleted_at    :datetime
#

class Section < ActiveRecord::Base
  include CacheWarmAble
  include Translatable
  belongs_to :instrument
  # Questions should not be deleted whenever a section is deleted
  has_many :questions
  has_many :translations, foreign_key: 'section_id', class_name: 'SectionTranslation', dependent: :destroy
  before_save :update_instrument_version, if: proc { |section| section.changed? }
  before_save :update_section_translation, if: proc { |section| section.title_changed? }
  before_destroy :update_instrument_version
  before_destroy :unset_section_questions
  acts_as_paranoid
  validates :title, presence: true

  def update_section_translation(status = true)
    translations.each do |translation|
      translation.update_attribute(:section_changed, status)
    end
  end

  def first_question_number
    questions.order(:number_in_instrument).try(:first).try(:number_in_instrument)
  end

  private

  def update_instrument_version
    instrument.update_instrument_version
  end

  def unset_section_questions
    questions.update_all(section_id: nil)
  end
end
