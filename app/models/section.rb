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
  include Translatable
  belongs_to :instrument
  has_many :questions #Do not put dependent destroy - want questions to remain whenever section is deleted
  has_many :translations, foreign_key: 'section_id', class_name: 'SectionTranslation', dependent: :destroy
  before_save :update_instrument_version, if: Proc.new { |section| section.changed? }
  before_save :update_section_translation, if: Proc.new { |section| section.title_changed? }
  before_destroy :update_instrument_version
  acts_as_paranoid
  validates :title, presence: true

  def update_section_translation(status = true)
    translations.each do |translation|
      translation.update_attribute(:section_changed, status)
    end
  end

  def as_json(options={})
    super((options || {}).merge({
                                    methods: [:first_question_number, :section_number]
                                }))
  end

  def first_question_number
    questions.order(:number_in_instrument).try(:first).try(:number_in_instrument)
  end

  def section_number
    instrument.sections.find_index(self)
  end

  private
  def update_instrument_version
    instrument.update_instrument_version
  end

end