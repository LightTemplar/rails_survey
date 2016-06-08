class AddDomainToScoreSection < ActiveRecord::Migration
  def change
    add_column :units, :domain, :string
    add_column :units, :sub_domain, :string
  end
end
