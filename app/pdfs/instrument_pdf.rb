class InstrumentPdf
  include Prawn::View
  include PdfUtils
  NUMBER_OF_COLUMNS = 2
  AFTER_TITLE_MARGIN = 15
  AFTER_HORIZONTAL_RULE_MARGIN = 15

  def initialize(instrument)
    super()
    @instrument = instrument
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
    text "#{@instrument.title} v#{@instrument.current_version_number}", size: 20, style: :bold
    move_down AFTER_TITLE_MARGIN
  end

  def content
    column_box([0, cursor], columns: NUMBER_OF_COLUMNS, width: bounds.width) do
      @instrument.questions.each do |question|
        format_question(question)
        text 'Special Response (circle one):  RF  DK  SK  NA'
        pad(5) { stroke_horizontal_rule }
        move_down AFTER_HORIZONTAL_RULE_MARGIN
      end
    end
  end

  def format_question(question)
    format_instructions(question.grid.instructions) if question.grid && question.number_in_grid == 1
    format_question_number(question)
    format_instructions(question.instructions)
    format_question_text(question.text)
    format_question_choices(question)
    pad_after_question(question)
  end
end
