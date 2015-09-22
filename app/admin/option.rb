ActiveAdmin.register Option do
  belongs_to :question
  permit_params :question_id, :text, :next_question, :number_in_question, :instrument_version_number

  sidebar 'Option Associations', only: :show do
    ul do
      li link_to 'Translations', admin_option_option_translations_path(params[:id])
    end
  end

  form do |f|
   f.inputs 'Option Details' do
    f.input :question, collection: Question.all.collect {|p| [p.text, p.id]} 
    f.input :text
    f.input :number_in_question
    f.input :next_question
   end
   f.actions
 end
  
end
