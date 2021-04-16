ActiveAdmin.register_page 'Reports' do
  content do
    images = Dir["#{Rails.root}/files/reports/*.png"]
    images.sort.each do |image|
      filename = image.split('/').last
      center = filename.split('-')
      domain = center.last.split('.').first
      label = if domain == '0'
                "Center #{center.first} center level"
              else
                "Center #{center.first} domain #{domain}"
              end
      para link_to label, controller: 'admin/reports', action: 'show', id: filename
    end
  end

  page_action :show, method: :get do
    send_file "#{Rails.root}/files/reports/#{params[:id]}", type: 'image/png', disposition: 'inline'
  end

  controller do
    skip_before_action :authenticate_active_admin_user, only: :show
  end
end
