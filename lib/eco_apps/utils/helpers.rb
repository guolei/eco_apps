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
        root = EcoApps::Util.env_value(YAML.load(app.url.to_s) )
        
        api = app.api
        api = YAML.load(api) if api.is_a?(String)
        begin
          path = api["url"][url_key.to_s] || ""
          options.each{|k,v| path.gsub!(":#{k}", v.to_s)}

          URI.parse(root).add_path(path).add_query(options[:params]).to_s
        rescue Exception => e
          raise "#{url_key} of #{app_name} seems not configured correctly in #{app_name}'s config/app_config.yml"
        end
      end

      def full_path_of(path, app = nil)
        return nil if path.blank?
        return path if path =~ /^(http|https):\/\//
        path = "/" + (path.split("/")-[""]).join("/")

        if Rails.env.production? and request.subdomains.first =~ /^www/
          prefix = "/#{(app||EcoApps.current.name)}"
        else
          prefix = (app.blank? ? "" : "#{EcoApps.base_url}/#{app}")
        end
        prefix + path
      end

      def authenticate_ip_address(extra = nil)
        legal_ip = EcoApps.legal_ip
        legal_ip += EcoApps::Util.convert_ip(extra) unless extra.blank?
        legal_ip.each do |ip|
          return if ip.matches?(request.remote_ip)
        end
        respond_to do |format|
          format.html{ render :text => "Access Denied!", :status => :forbidden }
          format.xml{ render :xml => {:info => "Access Denied!"}.to_xml, :status => :forbidden}
        end
      end
    end

    module SingletonMethods
      def ip_limited_access(options = {})
        extra = options.delete(:extra)
        before_filter(options){|c| c.authenticate_ip_address(extra)} if Rails.env.production?
      end
    end
  end
end

