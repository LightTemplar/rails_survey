# frozen_string_literal: true

ActiveAdmin.register Instrument do
  belongs_to :project
  navigation_menu :project
  actions :all, except: %i[new edit destroy]

  member_action :export, method: :get do
    redirect_to resource_path
  end

  index do
    column :id
    column :title do |instrument|
      link_to truncate(instrument.title, length: 50), export_admin_project_instrument_path(instrument.project_id, instrument.id)
    end
    actions
  end

  controller do
    def export
      instrument = Instrument.find(params[:id])
      filename = "#{instrument.title} #{Time.now.to_i}.csv"
      file = Tempfile.new(filename)
      File.write(file.path, instrument.to_csv, mode: 'w')
      send_file file, type: 'text/csv', filename: filename
    end
  end
end
