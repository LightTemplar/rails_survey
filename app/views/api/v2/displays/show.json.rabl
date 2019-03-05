# frozen_string_literal: true

object @display
cache @display

attributes :id, :position, :mode, :instrument_id, :title, :section_id

node :section_title do |d|
  d&.section&.title
end

node :question_count do |d|
  d.instrument_questions.size
end

node :range do |d|
  "#{d&.instrument_questions&.first&.number_in_instrument}-#{d&.instrument_questions&.last&.number_in_instrument}"
end

node :last_question_number_in_previous_display do |d|
  lqn = 0
  if d.position != 1
    previous_display = d.instrument.displays.where(position: d.position - 1).first
    if previous_display
      last_instrument_question = previous_display.instrument_questions.order(:number_in_instrument).last
      lqn = last_instrument_question.number_in_instrument if last_instrument_question
    end
  end
  lqn
end
