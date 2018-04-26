object @display
cache @display

attributes :id, :position, :mode, :instrument_id, :title

node :last_question_number_in_previous_display do |d|
  last_question_number = 0
  if d.position != 1
    previous_display = d.instrument.displays.where(position: d.position - 1).first
    if previous_display
      last_instrument_question = previous_display.instrument_questions.order(:number_in_instrument).last
      if last_instrument_question
        last_question_number = last_instrument_question.number_in_instrument
      end
    end
  end
  last_question_number
end

child :instrument_questions do
  extends 'api/v2/instrument_questions/index'
end
