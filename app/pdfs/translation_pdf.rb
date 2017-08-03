class TranslationPdf
  include Prawn::View
  include PdfUtils
  AFTER_TITLE_MARGIN = 15
  AFTER_HORIZONTAL_RULE_MARGIN = 10
  NUMBER_OF_COLUMNS = 2

  def initialize(instrument_translation)
    super()
    @instrument_translation = instrument_translation
    @instrument             = instrument_translation.instrument
    @language               = @instrument_translation.language
    @version                = @instrument.current_version_number
    header
    content
    number_odd_pages
    number_even_pages
  end

  def display_name
    "#{@instrument.title}_#{@version}_#{@language}.pdf"
  end

  private

  def header
    text "#{@instrument_translation.title} v#{@version}", size: 20, style: :bold
    text Settings.languages.to_h.key(@language)
    move_down AFTER_TITLE_MARGIN
  end

  def content
    column_box([0, cursor], columns: NUMBER_OF_COLUMNS, width: bounds.width) do
      @instrument.questions.each do |question|
        format_question(question)
        text special_responses
        stroke_horizontal_rule
        move_down AFTER_HORIZONTAL_RULE_MARGIN
      end
    end
  end

  def format_question(question)
    format_question_number(question)
    question_translation = @instrument_translation.translation_for(question)
    if question_translation
      format_question_instructions(question_translation.instructions)
      format_question_text(question_translation.text)
      format_question_choices(question, true)
      pad_after_question(question)
    end
  end
end
