ActiveAdmin.register QuestionTranslation do
  belongs_to :question
  permit_params :language, :text, :reg_ex_validation_message, :question_id
  actions :all, except: :new

  index do
    column :id
    column :question_id
    column :language
    column (:text) { |qst| raw(qst.text) }
    column :reg_ex_validation_message
    column :created_at
    column :updated_at
    column :question_changed
    actions
  end

  show do |_inst_trans|
    attributes_table do
      row :id
      row :question_id
      row :language
      row (:text) { |trans| raw(trans.text) }
      row :reg_ex_validation_message
      row :question_changed
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Question Translation Details' do
      f.input :question, collection: Question.all.collect { |p| [p.text, p.id] }
      f.input :language
      f.input :text
      f.input :reg_ex_validation_message
    end
    f.actions
  end

  controller do
    defaults collection_name: 'translations'
  end
end
