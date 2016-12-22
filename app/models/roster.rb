# == Schema Information
#
# Table name: rosters
#
#  id                        :integer          not null, primary key
#  project_id                :integer
#  uuid                      :string(255)
#  instrument_id             :integer
#  identifier                :string(255)
#  instrument_title          :string(255)
#  instrument_version_number :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class Roster < ActiveRecord::Base
  belongs_to :project
  belongs_to :instrument
  has_many :surveys, foreign_key: :roster_uuid, primary_key: :uuid, dependent: :destroy

end