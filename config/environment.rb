# Load the Rails application.
require File.expand_path('../application', __FILE__)

if ENV["TMPDIR"] && ENV["TMPDIR"].index("passenger")
  std_out = File.new(RAILS_ROOT + "/log/stdout.log","a")
  std_err = File.new(RAILS_ROOT + "/log/stderr.log","a")
  $stdout.reopen(std_out)
  $stderr.reopen(std_err)
end

# Initialize the Rails application.
RailsSurvey::Application.initialize!
