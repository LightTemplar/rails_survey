# frozen_string_literal: true

collection @loop_questions
cache ['v3-loop-questions', @loop_questions]

attributes :id, :instrument_question_id, :parent, :looped, :deleted_at, :option_indices, :same_display, :replacement_text
