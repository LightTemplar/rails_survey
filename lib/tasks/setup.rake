# frozen_string_literal: true

task setup: :environment do
  u = User.new
  u.email = 'user@example.com'
  u.password = u.password_confirmation = 'Password1'
  u.save!
  %w[admin manager analyst translator super_admin].each do |name|
    role = Role.find_by_name(name)
    role = Role.create(name: name) if role.nil?
    u.roles << role unless u.roles.include? role
  end
  p = Project.create!(name: 'Test Project', description: 'Test Project')
  u.projects << p
  u.save!
  du = DeviceUser.new
  du.name = 'Test User'
  du.username = 'test'
  du.active = true
  du.password = du.password_confirmation = 'Password1'
  du.save!
  du.projects << p
  du.save!
  ApiKey.create(device_user_id: du.id)
end
