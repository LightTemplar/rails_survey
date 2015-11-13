ActiveAdmin.register ApiKey do
  menu :if => proc{ current_user.super_admin? }
  permit_params :access_token

  index do
    column :id
    column :access_token
    actions
  end

  show do |key|
    attributes_table do
      row :id
      row :access_token
    end

    active_admin_comments
  end

  form do |f|
    unless f.object.new_record?
      f.inputs 'Api Key Details' do
        f.input :access_token
      end
    end
    f.actions
  end
end