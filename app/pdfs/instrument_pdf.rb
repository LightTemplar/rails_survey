# frozen_string_literal: true

class InstrumentPdf
  include Prawn::View
  include PdfUtils

  def initialize(instrument, column_count)
    super()
    @instrument = instrument
    @column_count = column_count.to_i
    register_fonts
    header
    content
    number_odd_pages
    number_even_pages
  end

  def display_name
    "#{@instrument.title}_#{@instrument.current_version_number}.pdf"
  end

  private

  def header
    text @instrument.title.to_s, size: FONT_SIZE + 6, style: :bold, align: :center
    text @instrument.language_name, align: :center
    text "version #: #{@instrument.current_version_number}", align: :center
    move_down AFTER_TITLE_MARGIN
  end

  def content
    column_box([0, cursor], columns: @column_count, width: bounds.width) do
      @instrument.sections.each do |section|
        format_section_text(section.title)
        section.displays.each do |display|
          format_display_text(display.title)
          move_down AFTER_TITLE_MARGIN
          display.instrument_questions.each do |iq|
            format_question(iq)
            move_down AFTER_QUESTION_MARGIN
          end
        end
      end
    end
  end

  def format_question(iq)
    if iq.question_type == 'INSTRUCTIONS'
      format_instructions(iq.question.instruction&.text) if iq.question.instruction
      format_instructions(iq.text)
      return
    end

    format_question_number(iq)

    instructions = iq.question.instruction&.text
    after_text_instructions = iq.question.after_text_instruction&.text
    pop_up_instructions = iq.question.pop_up_instruction&.text

    text sanitize_text("<i>#{instructions}</i>"), color: '808080', inline_format: true if instructions
    text sanitize_text(iq.text), inline_format: true
    text sanitize_text("<i><sup>*</sup>#{pop_up_instructions}</i>"), color: '808080', inline_format: true if pop_up_instructions
    text sanitize_text("<i>#{after_text_instructions}</i>"), color: '808080', inline_format: true if after_text_instructions

    move_down QUESTION_TEXT_MARGIN

    format_choice_instructions(iq.question&.option_set&.instruction&.text)
    format_question_choices(iq)
    pad_after_question(iq)
    format_special_responses(iq)
    format_skip_patterns(iq)
  end
end
