# frozen_string_literal: true

class TranslationPdf
  include Prawn::View
  include PdfUtils

  def initialize(instrument, language)
    super()
    @instrument = instrument
    @language = language
    register_fonts
    pdf_content
  end

  def display_name
    "#{@instrument.title}_#{@version}_#{@language}.pdf"
  end

  private

  def pdf_content
    header
    content
    number_odd_pages
    number_even_pages
  end

  def header
    text @instrument.title.to_s, size: FONT_SIZE + 6, style: :bold, align: :center
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

    bounds.move_past_bottom if y < MINIMUM_REMAINING_HEIGHT
    float do
      format_question_number(question)
    end

    text_array = []
    translated, instruction = instruction_text(question.question.instruction)
    text_array << { text: sanitize_text(instruction) + "\n", styles: [:italic], font: get_font(translated) } unless instruction.blank?
    status, text = question_text(question)
    if text.include? '</b>'
      strs = text.split('</b>')
      text_array << { text: sanitize_text(strs[0].delete('<b>')) + "\n", styles: [:bold], font: get_font(status) }
      text_array << { text: sanitize_text(strs[1]), font: get_font(status) }
    else
      text_array << { text: sanitize_text(text), font: get_font(status) }
    end
    box = Prawn::Text::Formatted::Box.new(text_array, at: [bounds.left + QUESTION_LEFT_MARGIN, cursor], document: self)
    box.render(dry_run: true)
    formatted_text_box text_array, at: [bounds.left + QUESTION_LEFT_MARGIN, cursor]
    move_down QUESTION_TEXT_MARGIN + box.height

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

  def get_font(translated)
    if translated && @language == 'km'
      'Noto Sans Khmer'
    elsif translated && @language == 'am'
      'Noto Sans Ethiopic'
    else
      'Noto Sans'
    end
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
