module PdfUtils
  QUESTION_LEFT_MARGIN = 30
  QUESTION_NUMBER_MARGIN = 5
  AFTER_INSTRUCTIONS_MARGIN = 10
  QUESTION_TEXT_MARGIN = 10
  AFTER_OPTIONS_MARGIN = 5
  MINIMUM_REMAINING_HEIGHT = 75
  OPTION_LEFT_MARGIN = 5
  CIRCLE_SIZE = 5
  SQUARE_SIZE = 10
  AFTER_OTHER_LINE_MARGIN = 25
  PAGE = '<page>'.freeze

  def format_question_number(question)
    text "#{question.number_in_instrument}.)", size: 18, style: :bold
    number_padding = question.number_in_instrument.to_s.length * 10
    draw_text question.question_type,       at: [bounds.left + QUESTION_LEFT_MARGIN + number_padding, cursor + 20], size: 10, style: :bold
    draw_text question.question_identifier, at: [bounds.left + QUESTION_LEFT_MARGIN + number_padding, cursor + 10], size: 10, style: :bold
    move_down QUESTION_NUMBER_MARGIN
  end

  def format_instructions(instructions)
    sanitizer = Rails::Html::FullSanitizer.new
    text sanitizer.sanitize(instructions), style: :italic
    move_down AFTER_INSTRUCTIONS_MARGIN unless instructions.blank?
  end

  def format_question_text(question_text)
    sanitizer = Rails::Html::WhiteListSanitizer.new
    tags = %w[b i u strikethrough sub sup]
    question_text = question_text.delete("\n")
    question_text = question_text.gsub('</p>', "\n")
    question_text = question_text.gsub('</div>', "\n")
    question_text = question_text.gsub('<br>', "\n")
    text sanitizer.sanitize(question_text, tags: tags), inline_format: true
    move_down QUESTION_TEXT_MARGIN
  end

  def format_question_choices(question, translated = false)
    if question.non_special_options? && !question.slider_variant?
      question.non_special_options.each do |option|
        draw_choice(option, translated)
      end
    elsif question.grid_labels?
      question.grid_labels.each do |label|
        draw_choice(label, translated)
      end
    elsif question.slider_variant?
      draw_slider(question, translated)
    end
    draw_other(question) if question.other?
    move_down AFTER_OPTIONS_MARGIN
  end

  def draw_choice(choice, translated)
    bounds.move_past_bottom if y < MINIMUM_REMAINING_HEIGHT
    translation = @instrument_translation.translation_for(choice) if translated
    if choice.class.name == 'GridLabel'
      stroke_circle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], CIRCLE_SIZE
      draw_bounding_box(translation.try(:label), choice.grid) if translated
      draw_bounding_box(choice.label, choice.grid) unless translated
    elsif choice.question.list_of_boxes_variant?
      text translation.try(:text) if translated
      text choice.text unless translated
      pad(10) { stroke_horizontal_rule }
    else
      stroke_circle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], CIRCLE_SIZE if choice.question.select_one_variant?
      stroke_rectangle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], SQUARE_SIZE, SQUARE_SIZE if choice.question.select_multiple_variant?
      draw_option_text(translation) if translated
      draw_option_text(choice) unless translated
    end
  end

  def draw_option_text(option)
    if option.class.name == 'OptionTranslation'
      option_text = option.try(:text)
      option = option.option
    else
      option_text = option.text
    end
    if option.next_question?
      next_question = option.instrument.questions.where(question_identifier: option.next_question).try(:first)
      if next_question.nil?
        draw_bounding_box("#{option_text} (<color rgb='ff0000'>#{skip_error(option)}</color>)", option.question, true)
      else
        draw_bounding_box("#{option_text} (#{skip_to}#{next_question.number_in_instrument})", option.question)
      end
    else
      draw_bounding_box(option_text, option.question)
    end
  end

  def draw_bounding_box(text_string, question, format = false)
    box_bounds = [bounds.left + OPTION_LEFT_MARGIN + 10, cursor]
    box_bounds = [bounds.left + OPTION_LEFT_MARGIN + 20, cursor - 5] if question.select_multiple_variant?
    bounding_box(box_bounds, width: bounds.width - (OPTION_LEFT_MARGIN * 2) - 10) do
      text text_string, inline_format: format
    end
  end

  def draw_other(question)
    left_pos = bounds.left + OPTION_LEFT_MARGIN
    right_pos = bounds.right - OPTION_LEFT_MARGIN - 10
    if question.question_type == 'SELECT_ONE_WRITE_OTHER'
      stroke_circle [left_pos, cursor - 5], CIRCLE_SIZE
      horizontal_line left_pos + 10, right_pos, at: cursor - 10
    elsif question.question_type == 'SELECT_MULTIPLE_WRITE_OTHER'
      stroke_rectangle [left_pos, cursor - 5], SQUARE_SIZE, SQUARE_SIZE
      horizontal_line left_pos + 20, right_pos, at: cursor - 15
    end
    move_down AFTER_OTHER_LINE_MARGIN
  end

  def draw_slider(question, translated)
    left_pos = bounds.left + OPTION_LEFT_MARGIN
    right_pos = bounds.right - OPTION_LEFT_MARGIN
    step = (right_pos - left_pos) / 10
    horizontal_line left_pos, right_pos, at: cursor - 10
    0.upto(9) do |n|
      draw_text (n + 1).to_s, at: [left_pos + (n * step), cursor - 5]
    end
    return unless question.question_type == 'LABELED_SLIDER'
    move_down 10
    cursor_pos = cursor - 5
    width = (right_pos - left_pos) / question.non_special_options.count
    question.non_special_options.each_with_index do |option, index|
      bounding_box([left_pos + (width * index), cursor_pos], width: width) do
        if translated
          text @instrument_translation.translation_for(option).try(:text)
        else
          text option.text
        end
      end
    end
  end

  def pad_after_question(question)
    return if Settings.question_with_options.include?(question.question_type)
    if question.question_type == 'FREE_RESPONSE'
      move_down 200
    else
      move_down 50
    end
  end

  def number_odd_pages
    odd_options = {
      at: [bounds.right - 150, 0],
      width: 150,
      align: :right,
      page_filter: :odd,
      start_count_at: 1
    }
    number_pages PAGE, odd_options
  end

  def number_even_pages
    even_options = {
      at: [0, bounds.left],
      width: 150,
      align: :left,
      page_filter: :even,
      start_count_at: 2
    }
    number_pages PAGE, even_options
  end

  def skip_error(option)
    case @language
    when 'en'
      "Error Locating Question #{option.try(:next_question)} for skip pattern!"
    when 'es'
      "Error al localizar la pregunta #{option.try(:next_question)} para patrón de salto!"
    when 'sw'
      "Swali #{option.try(:next_question)} ambalo linafaa kufuata halikupatikana!"
    else
      "Error Locating Question #{option.try(:next_question)} for skip pattern!"
    end
  end

  def skip_to
    case @language
    when 'en'
      'If selected skip to #'
    when 'es'
      'Si está seleccionado, vaya a'
    when 'sw'
      'Ikichaguliwa ruka kwa #'
    else
      'If selected skip to #'
    end
  end

  def special_responses
    case @language
    when 'en'
      'Special Response (circle one): RF  DK  SK  NA'
    when 'es'
      'Respuesta Especial (circule uno):  NR  NS  SP  NA'
    when 'sw'
      'Jibu maalum (zunguka moja): KT  SJ  RK  SH'
    else
      'Special Response (circle one): RF  DK  SK  NA'
    end
  end
end
