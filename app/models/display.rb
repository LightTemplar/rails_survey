# == Schema Information
#
# Table name: displays
#
#  id            :integer          not null, primary key
#  mode          :string
#  position      :integer
#  instrument_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  title         :string
#  deleted_at    :datetime
#  section_title :string
#  section_id    :integer
#

class Display < ActiveRecord::Base
  belongs_to :instrument, touch: true
  has_many :instrument_questions, -> { order 'number_in_instrument' }, dependent: :destroy
  has_many :display_instructions, dependent: :destroy
  acts_as_paranoid
  has_paper_trail
  validates :title, presence: true
  validates :position, presence: true

  def set_section
    unless section_title.blank?
      section = instrument.sections.where(title: section_title).try(:first)
      unless section
        section = Section.create!(title: section_title, instrument_id: instrument_id)
      end
      self.section_id = section.id
      self.save
      reload
    end
  end

  def copy(instrument, display_type)
    if display_type == 'AS_IT_IS'
      copy = self.dup
      copy.instrument_id = instrument.id
      copy.position = instrument.displays.size + 1
      copy.save!
      instrument_questions.each do |iq|
        iq.copy(copy.id, instrument.id)
      end
    elsif display_type == 'ONE_QUESTION_PER_SCREEN'
      instrument_questions.order(:number_in_instrument).each_with_index { |iq, index|
        display_copy = Display.create!(mode: 'SINGLE', position: instrument.displays.size + index, instrument_id: instrument.id, title: "#{title}_#{index}")
        iq.copy(display_copy.id, instrument.id)
      }
    end
  end

  def move(destination_display_id, moved)
    destination = instrument.displays.where(id: destination_display_id).first
    if destination_display_id == -1
      destination = instrument.displays.create!(title: 'New Display',
        position: instrument.displays.size + 1, mode: 'MULTIPLE')
    end
    if destination && moved
      moved.each do |id|
        iq = instrument_questions.find(id)
        iq.display_id = destination.id
        iq.save!
      end
    end
    RenumberQuestionsWorker.perform_async(instrument.id)
    destination
  end

end
