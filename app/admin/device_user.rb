ActiveAdmin.register DeviceUser do

  index do
    selectable_column
    column :id
    column :name
    column :username
    column :active
    column :created_at
    column :updated_at
    actions
  end

  show do |user|
    attributes_table do
      row :id
      row :name
      row :username
      row :active
      row :created_at
      row :updated_at
      row 'Device User Projects' do
        ul do
          user.projects.each do |project|
            li { project.name }
          end
        end
      end
      row 'Device User Devices' do
        ul do
          user.devices.each do |device|
            li { device.label }
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'DeviceUser Details' do
      f.input :name
      f.input :username
      f.input :password, hint: 'Leave blank. Do not change.'
      f.input :password_confirmation
      f.input :active
      f.input :projects, :as => :check_boxes
      f.input :devices, :as => :check_boxes, member_label: :label
    end
    f.actions
  end
end