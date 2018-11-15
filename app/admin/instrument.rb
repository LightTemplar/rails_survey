ActiveAdmin.register Instrument do
  belongs_to :project
  permit_params :title, :language, :alignment, :previous_question_count, :child_update_count, :published, :show_instructions, :project_id
  scope_to :current_user, unless: proc { current_user.super_admin? }
  actions :all, except: :new

  sidebar 'Instrument Associations', only: :show do
    ul do
      li link_to 'Questions', admin_instrument_questions_path(params[:id])
      li link_to 'Translations', admin_instrument_instrument_translations_path(params[:id])
      li link_to 'Rosters', admin_instrument_rosters_path(params[:id])
    end
  end

  form do |f|
    f.inputs 'Instrument Details' do
      f.input :project, collection: Project.all { |i| [i.name, i.id] }
      f.input :title
      f.input :language, collection: Settings.languages
      f.input :published
      f.input :show_instructions
    end
    f.actions
  end
end
