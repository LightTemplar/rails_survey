# frozen_string_literal: true

collection @score_schemes

attributes :id, :title, :instrument_id, :deleted_at

node :score_unit_count, &:score_unit_count
