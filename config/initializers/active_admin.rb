ActiveAdmin.setup do |config|
  config.site_title = 'iSEE Admin Dashboard'
  config.site_title_link = :admin_root
  config.authentication_method = :authenticate_active_admin_user!
  config.current_user_method = :current_user
  config.logout_link_path = :destroy_user_session_path
  config.logout_link_method = :delete
  config.skip_before_action :authenticate_user_from_token!
  config.skip_before_action :authenticate_user!
  config.authorization_adapter = ActiveAdmin::PunditAdapter
  config.pundit_default_policy = 'ApplicationPolicy'
  config.batch_actions = true
  config.filters = false
  config.breadcrumb = false
  config.comments = false

  config.namespace :admin do |admin|
    admin.build_menu :utility_navigation do |menu|
      menu.add label: 'Sidekiq', url: proc { sidekiq_path }
      menu.add label: 'iSEE Dashboard', url: proc { root_path }
      admin.add_current_user_to_menu  menu
      admin.add_logout_button_to_menu menu
    end
  end
end
