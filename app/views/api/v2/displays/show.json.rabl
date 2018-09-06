object @display
cache @display

attributes :id, :position, :mode, :instrument_id, :title, :section_title, :section_id

node :question_count do |d|
  d.instrument_questions.size
end

node :last_question_number_in_previous_display do |d|
  lqn = 0
  if d.position != 1
    previous_display = d.instrument.displays.where(position: d.position - 1).first
    if previous_display
      last_instrument_question = previous_display.instrument_questions.order(:number_in_instrument).last
      if last_instrument_question
        lqn = last_instrument_question.number_in_instrument
      end
    end
  end
  lqn
end
