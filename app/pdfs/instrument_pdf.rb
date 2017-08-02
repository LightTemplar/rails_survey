class InstrumentPdf
  include Prawn::View
  NUMBER_OF_COLUMNS = 2
  AFTER_TITLE_MARGIN = 15
  QUESTION_LEFT_MARGIN = 30
  INSTRUCTION_QUESTION_MARGIN = 10
  OPTION_LEFT_MARGIN = 5
  CIRCLE_SIZE = 5
  SQUARE_SIZE = 10
  AFTER_OPTIONS_MARGIN = 5
  AFTER_HORIZONTAL_RULE_MARGIN = 15
  MINIMUM_REMAINING_HEIGHT = 75
  QUESTION_TEXT_MARGIN = 10
  QUESTION_NUMBER_MARGIN = 5
  AFTER_OTHER_LINE_MARGIN = 25
  PAGE = '<page>'.freeze

  def initialize(instrument)
    super()
    @instrument = instrument
    @sanitizer = Rails::Html::FullSanitizer.new
    header
    content
    number_odd_pages
    number_even_pages
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
    format_question_number(question)
    format_instructions(question)
    text @sanitizer.sanitize(question.text)
    move_down QUESTION_TEXT_MARGIN
    draw_choices(question)
    pad_after_question(question)
  end

  def format_instructions(question)
    text (question.grid && question.number_in_grid == 1 ? @sanitizer.sanitize(question.grid.instructions) : @sanitizer.sanitize(question.instructions)), style: :italic
    move_down INSTRUCTION_QUESTION_MARGIN unless question.instructions.blank? && question.grid && question.grid.instructions.blank?
  end

  def format_question_number(question)
    text "#{question.number_in_instrument}.)", size: 18, style: :bold
    number_padding = question.number_in_instrument.to_s.length * 10
    text_box question.question_type,       at: [bounds.left + QUESTION_LEFT_MARGIN + number_padding, cursor + 20], size: 10, style: :bold
    text_box question.question_identifier, at: [bounds.left + QUESTION_LEFT_MARGIN + number_padding, cursor + 10], size: 10, style: :bold
    move_down QUESTION_NUMBER_MARGIN
  end

  def draw_choices(question)
    if question.non_special_options?
      question.non_special_options.each do |option|
        draw_choice(option)
      end
    elsif question.grid_labels?
      question.grid_labels.each do |label|
        draw_choice(label)
      end
    end
    draw_other(question) if question.other?
    move_down AFTER_OPTIONS_MARGIN
  end

  def draw_choice(choice)
    bounds.move_past_bottom if y < MINIMUM_REMAINING_HEIGHT
    if choice.class.name == 'GridLabel'
      stroke_circle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], CIRCLE_SIZE
      draw_bounding_box(choice.label, choice.grid)
    elsif choice.question.list_of_boxes_variant?
      text choice.text
      pad(10) { stroke_horizontal_rule }
    else
      stroke_circle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], CIRCLE_SIZE if choice.question.select_one_variant?
      stroke_rectangle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], SQUARE_SIZE, SQUARE_SIZE if choice.question.select_multiple_variant?
      draw_option_text(choice)
    end
  end

  def draw_option_text(option)
    if option.next_question?
      next_question = option.instrument.questions.where(question_identifier: option.next_question).try(:first)
      if next_question.nil?
        draw_bounding_box("#{option.text} (<color rgb='ff0000'>Error Locating Question #{option.next_question} for skip pattern!</color>)", option.question, true)
      else
        draw_bounding_box("#{option.text} (If selected skip to # #{next_question.number_in_instrument})", option.question)
      end
    else
      draw_bounding_box(option.text, option.question)
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

  def pad_after_question(question)
    return if Settings.question_with_options.include?(question.question_type)
    if question.question_type == 'FREE_RESPONSE'
      move_down 200
    else
      move_down 50
    end
  end
end
