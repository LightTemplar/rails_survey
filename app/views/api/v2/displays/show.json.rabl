object @display
cache @display

attributes :id, :position, :mode, :instrument_id, :title

node :last_question_number_in_previous_display do |d|
  last_question_number = 0
  if d.position != '1'
    previous_display = Display.where(position: d.position.to_i - 1).first
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
  attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id, :identifier

  node :type do |iq|
    iq.question.question_type if iq.question
  end

  node :text do |iq|
    iq.question.text if iq.question
  end

  node :question_set_id do |iq|
    iq.question.question_set_id if iq.question
  end

  node :option_set_id do |iq|
    iq.question.option_set_id if iq.question
  end
end
