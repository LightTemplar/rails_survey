collection @questions
# cache ["#{@instrument.id}/#{@questions.count}/#{@questions.max_by(&:updated_at).updated_at}/#{@page_num}", @questions]

if @page_num.blank?
  extends 'api/v1/frontend/questions/only'
else
  extends 'api/v1/frontend/questions/show'
  node(:_links) do
    paginate @questions
  end
end
