# frozen_string_literal: true

ActiveAdmin.register SurveyScore do
  belongs_to :score_scheme
  navigation_menu :score_scheme

  actions :all, except: %i[destroy edit new]

  config.per_page = [50, 100]
  config.filters = true
  filter :survey_id
  filter :identifier
  filter :score_sum

  collection_action :download_all, method: :get do
    redirect_to resource_path
  end

  member_action :score, method: :get do
    redirect_to resource_path
  end

  member_action :download, method: :get do
    redirect_to resource_path
  end

  action_item :download_all, only: :index do
    link_to 'Download Survey Scores', download_all_admin_score_scheme_survey_scores_path(params[:score_scheme_id])
  end

  action_item :score, only: :show do
    link_to 'Score', score_admin_score_scheme_survey_score_path(params[:score_scheme_id], params[:id])
  end

  action_item :download, only: :show do
    link_to 'Download', download_admin_score_scheme_survey_score_path(params[:score_scheme_id], params[:id])
  end

  sidebar 'Survey Score Associations', only: :show do
    ul do
      li link_to 'Domain Scores', admin_survey_score_domain_scores_path(params[:id])
      li link_to 'Subdomain Scores', admin_survey_score_subdomain_scores_path(params[:id])
    end
  end

  index do
    column :id
    column :survey
    column 'Identifier', :identifier
    column 'Score', :score_sum
    actions
  end

  show do
    attributes_table do
      row :id
      row :survey
      row :score_scheme
      row :identifier
      row :score_sum
      row :score_data do
        unless survey_score.score_data.nil?
          data = []
          JSON.parse(survey_score.score_data).each { |arr| data << arr }
          table_for data do
            column 'domain' do |csv_row|
              csv_row[7]
            end
            column 'subdomain' do |csv_row|
              csv_row[8]
            end
            column 'unit' do |csv_row|
              csv_row[9]
            end
            column 'weight' do |csv_row|
              csv_row[10]
            end
            column 'unit score' do |csv_row|
              csv_row[11]
            end
            column 'subdomain score' do |csv_row|
              csv_row[12]
            end
            column 'domain score' do |csv_row|
              csv_row[13]
            end
            column 'survey score' do |csv_row|
              csv_row[14]
            end
          end
        end
      end
    end
  end

  controller do
    def download_all
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      send_file score_scheme.download, type: 'text/csv', filename:
      "#{score_scheme.title.split.join('_')}_survey_scores_#{Time.now.to_i}.csv"
    end

    def score
      survey_score = SurveyScore.find params[:id]
      survey_score.generate_raw_scores
      redirect_to admin_score_scheme_survey_score_path(params[:score_scheme_id], params[:id])
    end

    def download
      survey_score = SurveyScore.find params[:id]
      filename = survey_score.identifier
      filename = survey_score.title if filename.blank?
      send_file survey_score.download, type: 'text/csv', filename:
      "#{filename}_#{Time.now.to_i}.csv"
    end
  end
end
