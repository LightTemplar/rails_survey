object @randomized_display_group
cache @randomized_display_group

attributes :id, :instrument_id, :title

child :display_groups do
  attributes :id, :randomized_display_group_id, :position, :title
end
