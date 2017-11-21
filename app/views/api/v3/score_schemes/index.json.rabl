collection @score_schemes
cache @score_schemes

attributes :id, :title, :instrument_id, :deleted_at

node :score_unit_count do |ss|
  ss.score_unit_count
end
