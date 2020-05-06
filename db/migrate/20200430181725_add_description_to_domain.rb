# frozen_string_literal: true

class AddDescriptionToDomain < ActiveRecord::Migration[5.1]
  def change
    add_column :domains, :name, :string
    add_column :subdomains, :name, :string
    add_column :score_units, :notes, :text
    add_column :option_scores, :notes, :text
  end
end
