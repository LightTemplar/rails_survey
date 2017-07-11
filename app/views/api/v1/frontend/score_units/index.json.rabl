collection @score_units
cache @score_units
extends 'api/v1/frontend/score_units/show'

unless @page_num.blank?
  node(:_links) do
    paginate @score_units
  end
end