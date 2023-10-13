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
      link_to "#{truncate(instrument.title, length: 50)} (download)",
              export_admin_project_instrument_path(instrument.project_id, instrument.id)
    end
    actions
  end

  controller do
    def export
      instrument = Instrument.find(params[:id])
      filename = "#{instrument.title} #{Time.now.to_i}.xlsx"
      file = Tempfile.new(filename)
      send_file instrument.to_excel(file), type: 'text/xlsx', filename: filename
    end
  end
end
