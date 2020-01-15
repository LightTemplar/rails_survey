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
          display.instrument_questions.each do |question|
            format_question(question)
            move_down AFTER_QUESTION_MARGIN
          end
        end
      end
    end
  end

  def format_question(question)
    if question.question.question_type == 'INSTRUCTIONS'
      format_instructions(question.question.instruction&.text) if question.question.instruction
      format_instructions(question.text)
      return
    end

    bounds.move_past_bottom if y < MINIMUM_REMAINING_HEIGHT
    float do
      format_question_number(question)
    end

    instructions = question.question.instruction&.text
    bounding_box([bounds.left + QUESTION_TEXT_LEFT_MARGIN, cursor], width: bounds.width - 30) do
      if question.question.instruction_after_text
        text sanitize_text(question.text), inline_format: true
        text sanitize_text("<i>#{instructions}</i>") + "\n", inline_format: true if instructions
      else
        text sanitize_text("<i>#{instructions}</i>") + "\n", inline_format: true if instructions
        text sanitize_text(question.text), inline_format: true
      end
      pop_up_instruction = question.question.pop_up_instruction&.text
      text sanitize_text("<i>#{pop_up_instruction}</i>") + "\n", inline_format: true if pop_up_instruction
    end
    move_down QUESTION_TEXT_MARGIN
    format_choice_instructions(question.question&.option_set&.instruction&.text)
    format_question_choices(question)
    pad_after_question(question)
    format_special_responses(question)
    format_skip_patterns(question)
  end
end
