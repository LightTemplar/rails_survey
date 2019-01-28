class TranslationPdf
  include Prawn::View
  include PdfUtils
  AFTER_TITLE_MARGIN = 15
  AFTER_HORIZONTAL_RULE_MARGIN = 10
  AFTER_QUESTION_MARGIN = 20
  NUMBER_OF_COLUMNS = 2
  FONT_SIZE = 12

  def initialize(instrument, language)
    super()
    @instrument = instrument
    @language = language
    register_fonts
    pdf_content
  end

  def register_fonts
    font_families.update(
      "Noto Sans Khmer" => {
        normal: "#{Rails.root}/app/pdfs/fonts/NotoSansKhmer-Regular.ttf",
        bold: "#{Rails.root}/app/pdfs/fonts/NotoSansKhmer-Bold.ttf",
        italic: "#{Rails.root}/app/pdfs/fonts/NotoSansKhmer-Thin.ttf"
      },
      "Noto Sans Ethiopic" => {
        normal: "#{Rails.root}/app/pdfs/fonts/NotoSansEthiopic-Regular.ttf",
        bold: "#{Rails.root}/app/pdfs/fonts/NotoSansEthiopic-Bold.ttf",
        italic: "#{Rails.root}/app/pdfs/fonts/NotoSansEthiopic-Thin.ttf"
      }
    )
  end

  def display_name
    "#{@instrument.title}_#{@version}_#{@language}.pdf"
  end

  private

  def pdf_content
    font_size FONT_SIZE
    header
    content
    number_odd_pages
    number_even_pages
  end

  def header
    text "#{@instrument.title}", size: FONT_SIZE + 6, style: :bold, align: :center
    text @instrument.language_name(@language), align: :center
    text "version #: #{@instrument.current_version_number}", align: :center
    move_down AFTER_TITLE_MARGIN
  end

  def content
    column_box([0, cursor], columns: NUMBER_OF_COLUMNS, width: bounds.width) do
      @instrument.displays.each do |display|
        translated, text = display_text(display)
        apply_font(:format_display_text, text, translated)
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
      translated, text = instruction_text(display_instruction.instruction)
      apply_font(:format_instructions, text, translated)
    end
    format_question_number(question)
    translated, instruction = instruction_text(question.question.instruction)
    apply_font(:format_instructions, instruction, translated)
    status, text = question_text(question)
    apply_font(:format_question_text, text, status)
    ts, tt = instruction_text(question.question.try(:option_set).try(:instruction))
    apply_font(:format_choice_instructions, tt, ts)
    format_question_choices(question, @language)
    pad_after_question(question)
    format_special_responses(question)
    format_skip_patterns(question)
  end

  def question_text(question)
    qt = question.question.text
    translation = question.question.translations.where(language: @language).first
    qt = translation.text if translation
    [!translation.nil?, qt]
  end

  def display_text(display)
    d_text = display.title
    translation = display.display_translations.where(language: @language).first
    d_text = translation.text if translation
    [!translation.nil?, d_text]
  end

  def instruction_text(instruction)
    return [false, ''] if instruction.nil?
    text = instruction.text
    translation = instruction.instruction_translations.where(language: @language).first
    text = translation.text if translation
    [!translation.nil?, text]
  end

  def apply_font(method, args, translated)
    if translated && @language == 'km'
      font('Noto Sans Khmer') do
        send(method, args)
      end
    elsif translated && @language == 'am'
      font('Noto Sans Ethiopic') do
        send(method, args)
      end
    else
      send(method, args)
    end
  end
end
