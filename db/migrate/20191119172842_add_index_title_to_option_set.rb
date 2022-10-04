# frozen_string_literal: true

class AddIndexTitleToOptionSet < ActiveRecord::Migration[4.2]
  def change
    add_index :option_sets, :title, unique: true
  end
end
