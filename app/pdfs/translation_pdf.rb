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
      @instrument.sections.each do |section|
        format_section_text(section_text(section))
        section.displays.each do |display|
          format_display_text(display_text(display))
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
    question.display_instructions.each do |display_instruction|
      format_instructions(instruction_text(display_instruction.instruction))
    end

    bounds.move_past_bottom if y < MINIMUM_REMAINING_HEIGHT
    float do
      format_question_number(question)
    end

    text_array = []
    instruction = instruction_text(question.question.instruction)
    if question.question.instruction_after_text
      text_array = question_text_array(question, text_array)
      text_array << { text: sanitize_text(instruction) + "\n", styles: [:italic] } unless instruction.blank?
    else
      text_array << { text: sanitize_text(instruction) + "\n", styles: [:italic] } unless instruction.blank?
      text_array = question_text_array(question, text_array)
    end
    pop_up_instruction = instruction_text(question.question.pop_up_instruction)
    text_array << { text: sanitize_text(pop_up_instruction) + "\n", styles: [:italic] } unless instruction.blank?
    box = Prawn::Text::Formatted::Box.new(text_array, at: [bounds.left + QUESTION_LEFT_MARGIN, cursor], document: self)
    box.render(dry_run: true)
    formatted_text_box text_array, at: [bounds.left + QUESTION_LEFT_MARGIN, cursor]
    move_down QUESTION_TEXT_MARGIN + box.height

    format_choice_instructions(instruction_text(question.question&.option_set&.instruction))
    format_question_choices(question, @language)
    pad_after_question(question)
    format_special_responses(question)
    format_skip_patterns(question)
  end

  def question_text_array(question, text_array)
    text = question_text(question)
    if text.include? '</b>'
      strs = text.split('</b>')
      text_array << { text: sanitize_text(strs[0].delete('<b>')) + "\n" }
      text_array << { text: sanitize_text(strs[1]) }
    else
      text_array << { text: sanitize_text(text) }
    end
  end

  def question_text(question)
    qt = question.question.text
    translation = question.question.translations.where(language: @language).first
    qt = translation.text if translation
    qt
  end

  def display_text(display)
    d_text = display.title
    translation = display.display_translations.where(language: @language).first
    d_text = translation.text if translation
    d_text
  end

  def instruction_text(instruction)
    return '' if instruction.nil?

    text = instruction.text
    translation = instruction.instruction_translations.where(language: @language).first
    text = translation.text if translation
    text
  end

  def section_text(section)
    d_text = section.title
    translation = section.translations.where(language: @language).first
    d_text = translation.text if translation
    d_text
  end
end
