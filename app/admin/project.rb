# frozen_string_literal: true

ActiveAdmin.register Project do
  actions :all, except: [:destroy]
  permit_params :name, :description, :survey_aggregator

  sidebar 'Project Associations', only: :show do
    ul do
      li link_to 'Surveys', admin_project_surveys_path(params[:id])
      li link_to 'Exports', admin_project_response_exports_path(params[:id])
      li link_to 'Questions', admin_project_questions_path(params[:id])
      li link_to 'Schemes', admin_project_score_schemes_path(params[:id])
    end
  end

  index do
    column :id
    column :name do |project|
      link_to truncate(project.name, length: 50), admin_project_path(project.id)
    end
    column :description do |project|
      truncate(project.description, length: 100)
    end
    actions
  end

  show do |project|
    attributes_table do
      row :id
      row :name
      row :description
      row :created_at
      row :updated_at
      row :users do
        ul do
          project.users.each do |user|
            li { user.email }
          end
        end
      end
      row :survey_aggregator
    end
  end

  form do |f|
    f.inputs 'Project Details' do
      f.input :name
      f.input :description
      f.input :survey_aggregator, collection: Settings.metric_keys
    end
    f.actions
  end
end
