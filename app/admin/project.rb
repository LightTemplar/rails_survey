ActiveAdmin.register Project do
  sidebar 'Project Associations', only: :show do
    ul do
      li link_to 'Instruments', admin_project_instruments_path(params[:id])
    end
  end
  menu priority: 4
  permit_params :name, :description

  index do
    selectable_column
    column :id
    column :name do |text|
      truncate(text.name, length: 50)
    end
    column :description do |text|
      truncate(text.description, length: 100)
    end
    column :created_at
    column :updated_at
    actions
  end

  show do |project|
    attributes_table do
      row :id
      row :name
      row :description
      row :created_at
      row :updated_at
      row :users do
        ul do
          project.users.each do |user|
            li {user.email}
          end
        end
      end
    end
    active_admin_comments
  end


end
