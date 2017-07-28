module ApplicationHelper
  include ProjectsHelper
  include SessionsHelper
  def link_to_add_fields(name, f, association, options = {})
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
    link_to(name, '#', class: "add_fields #{options[:class]}", data: { id: id, fields: fields.delete("\n") })
  end

  def sanitized_base
    return '' unless ENV['BASE_URL']
    url = ENV['BASE_URL'].dup
    url[0] = '' if url[0] == '/'
    url
  end
end
