# frozen_string_literal: true

# == Schema Information
#
# Table name: rosters
#
#  id                        :integer          not null, primary key
#  project_id                :integer
#  uuid                      :string
#  instrument_id             :integer
#  identifier                :string
#  instrument_title          :string
#  instrument_version_number :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class Roster < ApplicationRecord
  belongs_to :project
  belongs_to :instrument
  has_many :surveys, foreign_key: :roster_uuid, primary_key: :uuid, dependent: :destroy
end
