# frozen_string_literal: true

class AddRedFlagsToOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :red_flags do |t|
      t.integer :instrument_question_id
      t.integer :instruction_id
      t.string :option_identifier
      t.boolean :selected, default: true

      t.timestamps
    end
    add_index :red_flags, :instrument_question_id
    add_index :red_flags, :instruction_id
    add_index :red_flags, %i[instrument_question_id instruction_id option_identifier], unique: true, name: 'instrument_question_instruction_option'

    add_index :instructions, :title, unique: true unless index_exists?(:instructions, :title)
    add_index :api_keys, :device_user_id unless index_exists?(:api_keys, :device_user_id)
    add_index :condition_skips, :instrument_question_id unless index_exists?(:condition_skips, :instrument_question_id)
    add_index :device_users, :username, unique: true unless index_exists?(:device_users, :username)
    add_index :roles, :name unless index_exists?(:roles, :name)
    add_index :user_roles, :role_id unless index_exists?(:user_roles, :role_id)
    add_index :user_roles, :user_id unless index_exists?(:user_roles, :user_id)
  end
end
