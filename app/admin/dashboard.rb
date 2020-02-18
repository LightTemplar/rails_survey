# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    panel 'Projects' do
      table_for Project.all.each do
        column('Name') { |project| link_to project.name, admin_project_path(project.id) }
        column('Responses') { |project| link_to 'Survey Responses', admin_project_surveys_path(project.id) }
        column('Exports') { |project| link_to 'Survey Exports', admin_project_response_exports_path(project.id) }
        column('Questions') { |project| link_to 'Survey Questions', admin_project_questions_path(project.id) }
      end
    end
  end

  def index
    authorize :dashboards, :index?
  end
end
