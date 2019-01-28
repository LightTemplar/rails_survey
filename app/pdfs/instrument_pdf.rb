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
    text "#{@instrument.title}", size: FONT_SIZE + 6, style: :bold, align: :center
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
      instructions = display_instruction.instruction.try(:text)
      format_instructions(instructions) if instructions
    end
    format_question_number(question)
    instruction = question.question.instruction.try(:text)
    format_instructions(instruction) if instruction
    format_question_text(question.text)
    format_choice_instructions(question.question.try(:option_set).try(:instruction).try(:text))
    format_question_choices(question)
    pad_after_question(question)
    format_special_responses(question)
    format_skip_patterns(question)
  end
end
