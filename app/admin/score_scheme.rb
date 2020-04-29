# frozen_string_literal: true

ActiveAdmin.register ScoreScheme do
  belongs_to :project
  navigation_menu :project

  actions :all, except: %i[destroy edit new]

  member_action :download, method: :get do
    redirect_to resource_path
  end

  action_item :download, only: :show do
    link_to 'Download', download_admin_project_score_scheme_path(params[:project_id], params[:id])
  end

  sidebar 'Scheme Associations', only: :show do
    ul do
      li link_to 'Centers', admin_score_scheme_centers_path(params[:id])
      li link_to 'Scores', admin_score_scheme_survey_scores_path(params[:id])
      li link_to 'Domains', admin_score_scheme_domains_path(params[:id])
    end
  end

  index do
    column :id
    column :instrument
    column :title
    column :active
    column 'Survey Scores', :survey_scores do |ss|
      link_to ss.survey_scores.size.to_s, admin_score_scheme_survey_scores_path(ss.id)
    end
    actions
  end

  controller do
    def download
      project = Project.find(params[:project_id])
      score_scheme = project.score_schemes.find(params[:id])
      send_file score_scheme.export_file, type: 'text/xlsx', filename:
      "#{score_scheme.title.split.join('_')}_#{Time.now.to_i}.xlsx"
    end
  end
end
