collection @questions
cache @questions
if @page_num.blank?
  extends 'api/v1/frontend/questions/only'
else
  extends 'api/v1/frontend/questions/show'
  node(:_links) do
    paginate @questions
  end
end
