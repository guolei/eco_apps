class CoreService < ActiveResource::Base
  self.site = EcoApps.master_url

  class << self
    def reset_config
      app = EcoApps::App
      options = {
        :name => app.name,
        :url => app.url,
        :api => app.api,
        :database => YAML.load_file(Rails.root.join("config/database.yml"))}

      if EcoApps.in_master_app?
        app = App.find_or_create_by_name(options[:name])
        app.update_attributes(options)
      else
        begin
          self.post(:reset_config, :app => options)
        rescue ActiveResource::ForbiddenAccess
          raise 'Access denied by master app! Please make sure ip address is contained by intranet_ip which is set in GEM_DIR/eco_apps/lib/platform_config.yml'
        rescue Exception 
          raise "master_app_url '#{EcoApps.master_url}' is unreachable! Please change it in GEM_DIR/eco_apps/lib/platform_config.yml or APP_ROOT/config/app_config.yml and make sure the master app starts at this address."
        end
      end
    end

    def app(app_name)
      app_name = app_name.to_s
      if EcoApps.in_master_app?
        obj = App.find_by_name(app_name)
      else
        unless Rails.env == "production" or (config = EcoApps::App.configuration[Rails.env]).blank? or
            (local = config[app_name]).blank?
          return self.new(:name => local["name"], :url => local["url"],
            :api => YAML.dump(local["api"]), :database => (local["database"].blank? ? nil : YAML.dump(local["database"])))
        end
        obj = CoreService.find(app_name)
      end
      
      return obj if (!obj.blank? and obj.attributes["error"].blank?)
      raise("#{app_name} doesn't exist") 
    end
  end

end
