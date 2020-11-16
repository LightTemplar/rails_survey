ActiveAdmin.register ResponseExport do
  belongs_to :project
  permit_params :project_id, :instrument_id, :instrument_versions, :completion
  actions :all, except: %i[new edit]

  collection_action :export_surveys, method: :get do
    redirect_to resource_path
  end

  action_item :export_surveys do
    link_to 'Export Surveys', export_surveys_admin_project_response_exports_path(params[:project_id])
  end

  member_action :long_download, method: :get do
    redirect_to resource_path, notice: 'Download successful!'
  end
  member_action :wide_download, method: :get do
    redirect_to resource_path, notice: 'Download successful!'
  end
  member_action :short_download, method: :get do
    redirect_to resource_path, notice: 'Download successful!'
  end

  index do
    column :id do |export|
      link_to export.id, admin_project_response_export_path(export.instrument_id, export.id) if export.instrument_id
    end
    column 'Instrument', sortable: :instrument_title do |export|
      instrument = Instrument.find_by_id(export.instrument_id) if export.instrument_id
      instrument ? (link_to instrument.title, admin_project_instrument_path(instrument.project_id, instrument)) : ''
    end
    column :instrument_versions do |export|
      export.instrument_versions.join(',') if export.instrument_versions
    end
    column 'Progress', :completion
    column 'Format', :long_done do |export|
      if export.completion < 100
        'exporting'
      else
        link_to 'Long', long_download_admin_project_response_export_path(params[:project_id], export.id)
      end
    end
    column 'Format', :wide_done do |export|
      if export.completion < 100
        'exporting'
      else
        link_to 'Wide', wide_download_admin_project_response_export_path(params[:project_id], export.id)
      end
    end
    column 'Format', :short_done do |export|
      if export.completion < 100
        'exporting'
      else
        link_to 'Short', short_download_admin_project_response_export_path(params[:project_id], export.id)
      end
    end
    column :updated_at
    actions
  end

  controller do
    def long_download
      export = ResponseExport.find_by_id(params[:id])
      send_file export.export_file('long'), type: 'text/csv', filename:
      "#{export.instrument.title}_#{Time.now.to_i}_long.csv"
    end

    def wide_download
      export = ResponseExport.find_by_id(params[:id])
      send_file export.export_file('wide'), type: 'text/csv', filename:
      "#{export.instrument.title}_#{Time.now.to_i}_wide.csv"
    end

    def short_download
      export = ResponseExport.find_by_id(params[:id])
      send_file export.export_file('short'), type: 'text/csv', filename:
      "#{export.instrument.title}_#{Time.now.to_i}_short.csv"
    end

    def export_surveys
      project = Project.find(params[:project_id])
      project.instruments.each do |instrument|
        instrument.export_surveys if instrument.surveys.size > 0
      end
      redirect_to admin_project_response_exports_path(params[:project_id])
    end
  end
end
