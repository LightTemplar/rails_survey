# frozen_string_literal: true

class InstrumentPdf
  include Prawn::View
  include PdfUtils

  def initialize(instrument)
    super()
    @instrument = instrument
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
    column_box([0, cursor], columns: NUMBER_OF_COLUMNS, width: bounds.width) do
      @instrument.displays.each do |display|
        text "<u>#{display.title}</u>", align: :center, size: FONT_SIZE + 3, style: :bold, inline_format: true
        move_down AFTER_TITLE_MARGIN
        display.instrument_questions.each do |question|
          format_question(question)
          move_down AFTER_QUESTION_MARGIN
        end
      end
    end
  end

  def format_question(question)
    question.display_instructions.each do |display_instruction|
      instructions = display_instruction.instruction&.text
      format_instructions(instructions) if instructions
    end

    bounds.move_past_bottom if y < MINIMUM_REMAINING_HEIGHT # Needed to avoid float command messing up formatting
    float do # Do not move cursor position
      format_question_number(question)
    end
    text_array = []
    instructions = question.question.instruction&.text
    text_array << { text: sanitize_text(instructions) + "\n", styles: [:italic] } if instructions
    if question.text.include? '</b>'
      strs = question.text.split('</b>')
      text_array << { text: sanitize_text(strs[0].delete('<b>')) + "\n", styles: [:bold] }
      text_array << { text: sanitize_text(strs[1]) }
    else
      text_array << { text: sanitize_text(question.text) }
    end
    box = Prawn::Text::Formatted::Box.new(text_array, at: [bounds.left + QUESTION_LEFT_MARGIN, cursor], document: self)
    box.render(dry_run: true) # Find out the heigh of the text since text_box does not move cursor in the same way as text
    formatted_text_box text_array, at: [bounds.left + QUESTION_LEFT_MARGIN, cursor]
    move_down QUESTION_TEXT_MARGIN + box.height
    format_choice_instructions(question.question&.option_set&.instruction&.text)
    format_question_choices(question)
    pad_after_question(question)
    format_special_responses(question)
    format_skip_patterns(question)
  end
end
