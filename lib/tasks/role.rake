namespace :db do
  task roles: :environment do
    roles = %w(user admin manager analyst translator super_admin)
    roles.each do |name|
      role = Role.find_by_name(name)
      Role.create(name: name) if role.nil?
    end
  end
end