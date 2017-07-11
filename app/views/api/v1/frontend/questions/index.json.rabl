collection @questions
cache @questions

extends 'api/v1/frontend/questions/show'
unless @page_num.blank?
  node(:_links) do
    paginate @questions
  end
end
