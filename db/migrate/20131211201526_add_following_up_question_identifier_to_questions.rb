class AddFollowingUpQuestionIdentifierToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :following_up_question_identifier, :string
  end
end
