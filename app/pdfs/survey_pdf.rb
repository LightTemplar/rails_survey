# frozen_string_literal: true

class SurveyPdf
  include Prawn::View
  include PdfUtils
  include Sanitizer

  def initialize(survey, column_count)
    super()
    @responses = survey.responses
    @instrument = survey.instrument
    @column_count = column_count
    register_fonts
    header
    content
    number_odd_pages
    number_even_pages
  end

  private

  def header
    text @instrument.title.to_s, size: 16, style: :bold, align: :center
    text @instrument.language_name, align: :center
    text "version #: #{@instrument.current_version_number}", align: :center
    move_down 15
  end

  def content
    column_box([0, cursor], columns: @column_count, width: bounds.width) do
      @instrument.sections.each do |section|
        format_section_text(section.title)
        section.displays.each do |display|
          format_display_text(display.title)
          move_down 15
          display.instrument_questions.each do |iq|
            format_question(iq)
            move_down 20
          end
        end
      end
    end
  end

  def format_question(iq)
    response = @responses.find_by_question_identifier(iq.identifier)
    if iq.question.question_type == 'INSTRUCTIONS'
      format_instructions(iq.question.instruction&.text) if iq.question.instruction
      format_instructions(iq.text)
    else
      float do
        format_question_number(iq)
      end

      instructions = iq.question.instruction&.text
      after_text_instructions = iq.question.after_text_instruction&.text
      pop_up_instructions = iq.question.pop_up_instruction&.text
      bounding_box([bounds.left + 30, cursor], width: bounds.width - 30) do
        text sanitize_text("<i>#{instructions}</i>") + "\n", inline_format: true if instructions
        text sanitize_text(iq.text), inline_format: true
        text sanitize_text("** <i>#{pop_up_instructions}</i>") + "\n", inline_format: true if pop_up_instructions
        text sanitize_text("<i>#{after_text_instructions}</i>") + "\n", inline_format: true if after_text_instructions
      end

      indent(40) do
        pad(2) { text sanitize_text(iq.question&.option_set&.instruction&.text), style: :italic }
        if iq.nil? || iq.non_special_options.empty?
          font('Courier') { text response&.text }
        else
          response&.text.split(Settings.list_delimiter).each_with_index do |res, index|
            if iq.other? && res.to_i == iq.other_index
              text 'Other'
              font('Courier') { response&.other_response }
            else
              if iq.list_of_boxes_variant?
                text full_sanitizer.sanitize iq.non_special_options[index].to_s
                font('Courier') { text res }
              else
                font('Courier') { text full_sanitizer.sanitize iq.non_special_options[res.to_i].to_s }
              end
            end
          end
        end

        text response&.other_text
        text response&.special_response
      end
    end
  end
end
