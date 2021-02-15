# frozen_string_literal: true

class CreateDomainTranslations < ActiveRecord::Migration[5.1]
  def change
    create_table :domain_translations do |t|
      t.string :language
      t.string :text
      t.references :domain, index: true
      t.timestamps
    end
    create_table :subdomain_translations do |t|
      t.string :language
      t.string :text
      t.references :subdomain, index: true
      t.timestamps
    end
  end
end
