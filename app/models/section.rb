# frozen_string_literal: true

# == Schema Information
#
# Table name: sections
#
#  id                 :integer          not null, primary key
#  title              :string
#  created_at         :datetime
#  updated_at         :datetime
#  instrument_id      :integer
#  deleted_at         :datetime
#  position           :integer
#  randomize_displays :boolean          default(FALSE)
#

class Section < ApplicationRecord
  include Translatable
  belongs_to :instrument, touch: true
  has_many :displays, -> { order 'displays.position' }, dependent: :destroy
  has_many :instrument_questions, through: :displays
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

  def order_displays(order)
    ActiveRecord::Base.transaction do
      order.each_with_index do |value, index|
        display = displays.where(id: value).first
        display.update_columns(position: index + 1) if display && display.position != index + 1
      end
    end
    reload
    instrument.order_displays
  end

  def display_count
    displays.count
  end
end
