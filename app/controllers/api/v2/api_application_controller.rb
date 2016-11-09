module Api
  module V2
    class ApiApplicationController < ActionController::Metal
      abstract!
      include AbstractController::Callbacks
      include ActionController::RackDelegation
      include ActionController::StrongParameters
      include ActionController::Helpers
      include ActionController::RequestForgeryProtection
      include ActionController::Cookies
      include ActionController::Instrumentation
      protect_from_forgery with: :null_session
      before_filter :restrict_access
      before_filter :check_version_code

      private
      def restrict_access
        api_key = ApiKey.find_by_access_token(params[:access_token])
        head :unauthorized unless api_key
      end

      def check_version_code
        if params[:version_code]
          head :upgrade_required unless params[:version_code].to_i >= Settings.minimum_android_version_code
        end
      end

      def render(options={})
        self.status = options[:status] || 200
        self.content_type = 'application/json'
        body = Oj.dump(options[:json], mode: :compat)
        self.headers['Content-Length'] = body.bytesize.to_s
        self.response_body = body
      end

      ActiveSupport.run_load_hooks(:action_controller, self)

    end
  end
end