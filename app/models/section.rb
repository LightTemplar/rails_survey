# frozen_string_literal: true

# == Schema Information
#
# Table name: sections
#
#  id            :integer          not null, primary key
#  title         :string
#  created_at    :datetime
#  updated_at    :datetime
#  instrument_id :integer
#  deleted_at    :datetime
#  position      :integer
#

class Section < ActiveRecord::Base
  include Translatable
  belongs_to :instrument, touch: true
  has_many :displays, -> { order 'position' }, dependent: :destroy
  has_many :translations, foreign_key: 'section_id', class_name: 'SectionTranslation', dependent: :destroy

  acts_as_paranoid
  acts_as_list scope: :instrument

  validates :instrument_id, presence: true, allow_blank: false
  validates :title, presence: true, uniqueness: { scope: [:instrument_id] }

  def translated_text(language)
    return title if language == instrument.language

    translation = translations.where(language: language).first
    translation&.text ? translation.text : title
  end
end
