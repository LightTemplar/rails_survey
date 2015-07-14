ActiveAdmin.register ResponseExport do
  
  actions :all, except: [:new, :edit]
  
  member_action :download_exports, method: :get do
    redirect_to resource_path, notice: "Download successful!"
  end
  
  action_item :download, only: :show do
    link_to 'Download Files', download_exports_admin_response_export_path(response_export)
  end

  index do
    selectable_column
    column :id do |export|
      link_to export.id, admin_response_export_path(export.id)
    end
    column 'Instrument', sortable: :instrument_title do |export|
      instrument = Instrument.find_by_id(export.instrument_id) if export.instrument_id
      instrument ? (link_to instrument.title, admin_instrument_path(instrument)) : ''
    end
    column 'Project', sortable: :name do |export|
      project = Project.find_by_id(export.project_id) if export.project_id
      project ? (link_to project.name, admin_project_path(project)) : ''
    end
    column :instrument_versions do |export|
      export.instrument_versions.join(',') if export.instrument_versions
    end
    column :long_done
    column :wide_done
    column :short_done
    column :created_at
    column :updated_at
    actions
  end

  controller do   
    def download_exports
      response_export = ResponseExport.find_by_id(params[:id])
      if response_export
        root = File.join('files', 'exports').to_s
        file = File.new(root + "/#{Time.now.to_i}", "a+")
        Zip::OutputStream.open(file.path) do |zipfile|
          if response_export.long_format_url
            zipfile.put_next_entry("long_csv_#{Time.now.to_i}.csv")
            long_csv_data = open(response_export.long_format_url)
            zipfile.print IO.read(long_csv_data)
          end
          if response_export.wide_format_url
            zipfile.put_next_entry("wide_csv_#{Time.now.to_i}.csv")
            wide_csv_data = open(response_export.wide_format_url)
            zipfile.print IO.read(wide_csv_data)
          end
        end
        send_file file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "exports_#{Time.now.to_i}.zip"
        file.close
        DeleteFilesWorker.perform_in(2.minutes, file.path)
      end
    end  
  end

end