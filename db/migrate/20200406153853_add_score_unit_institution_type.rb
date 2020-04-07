# frozen_string_literal: true

class AddScoreUnitInstitutionType < ActiveRecord::Migration[5.1]
  def change
    add_column :score_units, :institution_type, :string
  end
end
