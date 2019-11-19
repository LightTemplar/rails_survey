# frozen_string_literal: true

class AddIndexTitleToOptionSet < ActiveRecord::Migration
  def change
    add_index :option_sets, :title, unique: true
  end
end
