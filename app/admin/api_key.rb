ActiveAdmin.register ApiKey do
  permit_params :access_token

  index do
    column :id
    column :access_token
    column :device_user
    actions
  end

  show do |_key|
    attributes_table do
      row :id
      row :access_token
      row :device_user
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
