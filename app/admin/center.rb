# frozen_string_literal: true

ActiveAdmin.register Center do
  belongs_to :score_scheme
  navigation_menu :score_scheme
  permit_params :identifier, :name, :center_type, :administration, :region, :department, :municipality
  actions :all, except: %i[destroy new]
  config.per_page = [50, 100]
  config.filters = false
  config.sort_order = 'id_asc'

  collection_action :download, method: :get do
    redirect_to resource_path
  end

  collection_action :mail_merge, method: :get do
    redirect_to resource_path
  end

  member_action :download_scores, method: :get do
    redirect_to resource_path
  end

  member_action :pdf_report, method: :get do
    redirect_to resource_path
  end

  action_item :download, only: :index do
    link_to 'Download', download_admin_score_scheme_centers_path(params[:score_scheme_id])
  end

  action_item :mail_merge, only: :index do
    link_to 'Mail Merge', mail_merge_admin_score_scheme_centers_path(params[:score_scheme_id])
  end

  index do
    column :id do |center|
      link_to center.id, admin_score_scheme_center_path(params[:score_scheme_id], center.id)
    end
    column :identifier
    column :name
    column 'Type', :center_type
    column :administration
    column :region
    column :department
    column :municipality
    column 'Survey Scores' do |center|
      center.ss_survey_scores(params[:score_scheme_id])
    end
    column 'Excel Reports' do |center|
      unless center.ss_survey_scores(params[:score_scheme_id]).empty?
        span { link_to 'English', download_scores_admin_score_scheme_center_path(params[:score_scheme_id], center.id, language: 'en') }
        span { link_to 'Spanish', download_scores_admin_score_scheme_center_path(params[:score_scheme_id], center.id, language: 'es') }
      end
    end
    column 'PDF Reports' do |center|
      unless center.ss_survey_scores(params[:score_scheme_id]).empty?
        span { link_to 'English', pdf_report_admin_score_scheme_center_path(params[:score_scheme_id], center.id, language: 'en') }
        span { link_to 'Spanish', pdf_report_admin_score_scheme_center_path(params[:score_scheme_id], center.id, language: 'es') }
      end
    end
  end

  controller do
    def download
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      send_file Center.download(score_scheme), type: 'application/zip',
                                               filename: "#{score_scheme.title.split.join('_')}_center_scores_#{Time.now.to_i}.zip"
    end

    def download_scores
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      center = Center.find params[:id]
      send_file center.formatted_scores(score_scheme, params[:language]), type: 'text/xlsx',
                                                                          filename: "#{center.identifier}-#{params[:language]}-#{Time.now.to_i}.xlsx"
    end

    def mail_merge
      ss = ScoreScheme.find(params[:score_scheme_id])
      send_file Center.mail_merge(ss), type: 'application/zip',
                                       filename: "#{ss.title.split.join('_')}_mail_merge_#{Time.now.to_i}.zip"
    end

    def pdf_report
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      center = Center.find params[:id]
      language = params[:language]
      pdf = ReportPdf.new(center, score_scheme, language)
      name = "#{center.identifier}-#{score_scheme.title.split.join('-')}-#{language}.pdf"
      file = Tempfile.new(name)
      pdf.save_as(file.path)
      send_file file, type: 'application/pdf', filename: name
    end
  end
end
