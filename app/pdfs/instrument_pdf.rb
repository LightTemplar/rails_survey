class InstrumentPdf
  include Prawn::View
  NUMBER_OF_COLUMNS = 2
  AFTER_TITLE_MARGIN = 15
  QUESTION_LEFT_MARGIN = 30
  INSTRUCTION_QUESTION_MARGIN = 10
  OPTION_LEFT_MARGIN = 5
  CIRCLE_SIZE = 5
  SQUARE_SIZE = 7
  AFTER_OPTION_MARGIN = 15
  AFTER_HORIZONTAL_RULE_MARGIN = 10
  MINIMUM_REMAINING_HEIGHT = 70
  QUESTION_TEXT_MARGIN = 10
  QUESTION_NUMBER_MARGIN = 5

  def initialize(instrument)
    super()
    @instrument = instrument
    @sanitizer = Rails::Html::FullSanitizer.new
    header
    content
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
        stroke_horizontal_rule
        move_down AFTER_HORIZONTAL_RULE_MARGIN
      end
    end
  end

  def format_question(question)
    format_question_number(question)
    text @sanitizer.sanitize(question.instructions), style: :italic
    move_down INSTRUCTION_QUESTION_MARGIN unless question.instructions.blank?
    text @sanitizer.sanitize(question.text)
    move_down QUESTION_TEXT_MARGIN
    draw_options(question) if question.non_special_options?
    pad_after_question(question)
  end

  def format_question_number(question)
    text "#{question.number_in_instrument}.)", size: 18, style: :bold
    number_padding = question.number_in_instrument.to_s.length * 10
    text_box question.question_type,       at: [bounds.left + QUESTION_LEFT_MARGIN + number_padding, cursor + 20], size: 10, style: :bold
    text_box question.question_identifier, at: [bounds.left + QUESTION_LEFT_MARGIN + number_padding, cursor + 10], size: 10, style: :bold
    move_down QUESTION_NUMBER_MARGIN
  end

  def draw_options(question)
    question.non_special_options.each do |option|
      draw_option(option)
    end
    draw_other(question) if question.other?
  end

  def draw_option(option)
    puts "Question number #{option.question.number_in_instrument}"
    puts "Before move cursor position: #{cursor}"
    bounds.move_past_bottom if cursor < MINIMUM_REMAINING_HEIGHT
    puts "After move cursor position: #{cursor}"
    if option.question.list_of_boxes_variant?
      text option.text
      horizontal_line bounds.left + OPTION_LEFT_MARGIN, bounds.right - OPTION_LEFT_MARGIN, at: cursor - 10
    else
      stroke_circle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], CIRCLE_SIZE if option.question.select_one_variant?
      stroke_rectangle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], SQUARE_SIZE, SQUARE_SIZE if option.question.select_multiple_variant?
      draw_option_text(option)
    end
    move_down AFTER_OPTION_MARGIN
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
    box_bounds = [bounds.left + OPTION_LEFT_MARGIN + 10, cursor - 5] if question.select_multiple_variant?
    bounding_box(box_bounds, width: bounds.width - (OPTION_LEFT_MARGIN * 2) - 10) do
      text text_string, inline_format: format
    end
  end

  def draw_other(question)
    stroke_circle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], CIRCLE_SIZE if question.question_type == 'SELECT_ONE_WRITE_OTHER'
    stroke_rectangle [bounds.left + OPTION_LEFT_MARGIN, cursor - 5], SQUARE_SIZE, SQUARE_SIZE if question.question_type == 'SELECT_MULTIPLE_WRITE_OTHER'
    horizontal_line bounds.left + OPTION_LEFT_MARGIN + 10, bounds.right - OPTION_LEFT_MARGIN - 10, at: cursor - 10
  end

  def pad_after_question(question)
    if question.question_type == 'FREE_RESPONSE'
      move_down 200
    else
      move_down 50
    end
  end
end
