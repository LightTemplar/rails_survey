class InstrumentPdf < Prawn::Document
  AfterTitleMargin = 15
  QuestionLeftMargin = 30
  InstructionQuestionMargin = 10
  OptionLeftMargin = 5
  CircleSize = 5
  SquareSize = 5
  AfterOptionMargin = 15
  AfterHorizontalRuleMargin = 10

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
    move_down AfterTitleMargin
  end

  def content
    @instrument.questions.each do |question|
      format_question(question)
      text 'Special Response (circle one):   RF   DK   SK   NA'
      stroke_horizontal_rule
      move_down AfterHorizontalRuleMargin
    end
  end

  def format_question(question)
    format_question_number(question)
    text @sanitizer.sanitize(question.instructions), style: :italic
    move_down InstructionQuestionMargin
    text @sanitizer.sanitize(question.text)
    draw_options(question) if question.options?
    pad_after_question(question)
  end

  def format_question_number(question)
    text "#{question.number_in_instrument}.)", size: 18, style: :bold
    number_padding = question.number_in_instrument.to_s.length * 10
    draw_text question.question_type,       at: [QuestionLeftMargin + number_padding, cursor + 15], size: 10, style: :bold
    draw_text question.question_identifier, at: [QuestionLeftMargin + number_padding, cursor + 5],  size: 10, style: :bold
  end

  def draw_options(question)
    question.options.each do |option|
      draw_option(option) { stroke_circle [OptionLeftMargin, cursor - 5], CircleSize } if question.select_one_variant?
      draw_option(option) { stroke_rectangle [OptionLeftMargin, cursor - 5], SquareSize, SquareSize } if question.select_multiple_variant?
      draw_line_option(option) if question.question_type == 'LIST_OF_TEXT_BOXES'
    end
    draw_other(question) if question.other?
  end

  def draw_option(option)
    yield
    span(500, position: OptionLeftMargin + 10) do
      if option.next_question?
        next_question = option.instrument.questions.where(question_identifier: option.next_question).try(:first)
        if next_question.nil?
          text "#{option.text} (<color rgb='ff0000'>Error Locating Question #{option.next_question} for skip pattern!</color>)", inline_format: true
        else
          text "#{option.text} (Skip pattern: Skip to # #{next_question.number_in_instrument})"
        end
      else
        text option.text
      end
    end
  end

  def draw_line_option(option)
    draw_text "#{option.text} _________________________________", at: [OptionLeftMargin, cursor - 5]
    move_down AfterOptionMargin
  end

  def draw_other(question)
    stroke_circle [OptionLeftMargin, cursor - 5], CircleSize if question.question_type == 'SELECT_ONE_WRITE_OTHER'
    stroke_rectangle [OptionLeftMargin, cursor - 5], SquareSize, SquareSize if question.question_type == 'SELECT_MULTIPLE_WRITE_OTHER'
    draw_text '____________________________________________', at: [OptionLeftMargin + 10, cursor - 10]
  end

  def pad_after_question(question)
    if question.question_type == 'FREE_RESPONSE'
      move_down 200
    else
      move_down 50
    end
  end
end
