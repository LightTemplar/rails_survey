# frozen_string_literal: true

ActiveAdmin.register DeviceSyncEntry do
  config.per_page = [50, 100, 200]
  config.filters = true
  filter :device_label
  actions :all, except: %i[new edit]

  index do
    selectable_column
    id_column
    column :device_uuid
    column :device_label
    column :project
    column :timezone
    column :created_at
    actions
  end
end
