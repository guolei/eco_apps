module EcoApps
  module Helpers
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.helper_method :url_of
      base.extend SingletonMethods
    end

    module InstanceMethods

      def url_of(app_name, url_key, options={})
        app = MasterService.app(app_name)

        root = app.url
        root = YAML.load(root) if root.is_a?(String)
        root = root[Rails.env] if root.is_a?(Hash)
        
        api = app.api
        api = YAML.load(api) if api.is_a?(String)
        begin
          path = api["url"][url_key.to_s] || ""
          options.each{|k,v| path.gsub!(":#{k}", v.to_s)}

          url = URI.parse(root)
          url.path +=  "/#{path}".gsub("//","/")
          query = ([url.query, (options[:params]||{}).to_query] - [nil, ""]).join("&")
          url.query = query unless query.blank?
          url.to_s
        rescue Exception => e
          raise "#{url_key} of #{app_name} seems not configured correctly in #{app_name}'s config/app_config.yml"
        end
      end

      def authenticate_ip_address(extra = nil)
        legal_ip = EcoApps.legal_ip
        legal_ip += EcoApps::Util.convert_ip(extra) unless extra.blank?
        legal_ip.each do |ip|
          return if ip.contains?(request.remote_ip)
        end
        respond_to do |format|
          format.html{ render :text => "Access Denied!" }
          format.xml{ render :xml => {:info => "Access Denied!"}.to_xml, :status => :forbidden}
        end
      end
    end

    module SingletonMethods
      def ip_limited_access(options = {})
        extra = options.delete(:extra)
        before_filter(options){|c| c.authenticate_ip_address(extra)} if Rails.env == "production"
      end
    end
  end
end

