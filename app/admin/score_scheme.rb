# frozen_string_literal: true

ActiveAdmin.register ScoreScheme do
  belongs_to :project
  navigation_menu :project

  config.filters = false

  actions :all, except: %i[destroy edit new]

  member_action :generate, method: :get do
    redirect_to resource_path
  end

  member_action :download, method: :get do
    redirect_to resource_path
  end

  member_action :score, method: :get do
    redirect_to resource_path
  end

  member_action :filter, method: :get do
    redirect_to resource_path
  end

  member_action :filter_scores, method: :post do
    redirect_to resource_path
  end

  action_item :generate, only: :show do
    link_to 'Generate PDF Reports', generate_admin_project_score_scheme_path(params[:project_id], params[:id])
  end

  action_item :download, only: :show do
    link_to 'Download PDF Reports', download_admin_project_score_scheme_path(params[:project_id], params[:id])
  end

  action_item :score, only: :show do
    link_to 'Generate Scores', score_admin_project_score_scheme_path(params[:project_id], params[:id])
  end

  action_item :filter, only: :show do
    link_to 'Filter Scores', filter_admin_project_score_scheme_path(params[:project_id], params[:id])
  end

  sidebar 'Score Scheme Associations', only: :show do
    ul do
      li link_to 'Survey Scores', admin_score_scheme_survey_scores_path(params[:id])
      li link_to 'Center Scores', admin_score_scheme_centers_path(params[:id])
      li link_to 'Domains', admin_score_scheme_domains_path(params[:id])
    end
  end

  index do
    column :id
    column :instrument
    column :title
    column :active
    actions
  end

  show do |score_scheme|
    attributes_table do
      row :instrument
      row :title
      row :active
      row :created_at
      row :updated_at
      row 'PDF Reports Progress' do
        "#{score_scheme.progress} of #{score_scheme.centers.size}"
      end
    end
  end

  controller do
    def generate
      score_scheme = ScoreScheme.find(params[:id])
      score_scheme.generate_pdf_reports
      redirect_to admin_project_score_scheme_path(params[:project_id], params[:id])
    end

    def download
      score_scheme = ScoreScheme.find(params[:id])
      send_file score_scheme.zip_pdf_reports, type: 'application/zip',
        filename: "#{score_scheme.title.split.join('-')}-#{Time.now.to_i}.zip"
    end

    def score
      score_scheme = ScoreScheme.find(params[:id])
      score_scheme.score
      redirect_to admin_project_score_scheme_path(params[:project_id], params[:id])
    end

    def filter; end

    def filter_scores
      weight = params[:filter][:score_unit_weight].to_f
      operator = params[:filter][:operator]
      score_scheme = ScoreScheme.find(params[:id])
      score_scheme.survey_scores.each do |survey_score|
        ScoreDataGeneratorWorker.perform_async(survey_score.id, operator, weight)
      end
      redirect_to admin_project_score_scheme_path(params[:project_id], params[:id])
    end
  end
end
