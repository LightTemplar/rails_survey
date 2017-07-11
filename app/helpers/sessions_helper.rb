module SessionsHelper
  def store_location
    session[:previous_url] = if request.fullpath == user_session_path || request.fullpath == new_user_session_path || request.fullpath == user_password_path || request.fullpath == new_user_password_path || request.fullpath == edit_user_password_path || request.fullpath == destroy_user_session_path || request.fullpath == user_checkga_path || request.xhr?
                               nil
                             else
                               request.fullpath
                             end
  end
end
