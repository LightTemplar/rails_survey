class AndroidUpdate < ActiveRecord::Base
  default_scope { order('version DESC') }
  attr_accessible :version, :apk_update
  has_attached_file :apk_update, :url  => "/:attachment/:id/:basename.:extension", :path => "updates/:attachment/:id/:basename.:extension"
  #octet-stream validation is for a binary file. 
  #TODO find out the specific validation for android apk
  validates_attachment_content_type :apk_update, :content_type => ["application/octet-stream"]

  def self.latest_version
   AndroidUpdate.first 
  end

end
