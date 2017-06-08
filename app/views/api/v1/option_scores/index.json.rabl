collection @option_scores
cache @option_scores
attributes :id, :score_unit_id, :option_id, :value, :label, :exists, :next_question, :created_at, :updated_at, :deleted_at

node :label do |os|
  os.label
end