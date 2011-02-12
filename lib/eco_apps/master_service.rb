require 'active_resource/base'

class MasterService < ActiveResource::Base
  class << self
    def reset_config
      options = EcoApps.current.eco_apps_config
      if EcoApps.in_master_app?
        EcoAppsStore.reset_config(options)
      else
        begin
          self.create(options)
        rescue ActiveResource::ForbiddenAccess
          raise 'Access denied by master app! Please make sure ip address is contained by intranet_ip which is set in GEM_DIR/eco_apps/lib/platform_config.yml'
        rescue Exception => e
          raise "master_app_url '#{EcoApps.master_app_url}' is unreachable! Please change it in GEM_DIR/eco_apps/lib/platform_config.yml or APP_ROOT/config/app_config.yml and make sure the master app starts at this address."
        end
      end
    end

    def app(app_name)
      app_name = app_name.to_s
      begin
        if EcoApps.in_master_app?
          options = EcoAppsStore.find_by_name(app_name).attributes
        else
          if Rails.env == "production"
            options = MasterService.find(app_name).attributes
          else
            options = EcoApps::App.fetch(app_name) { MasterService.find(app_name).attributes }
          end
        end
        EcoApps::App.new(options)
      rescue ActiveResource::ResourceNotFound
        raise("#{app_name} doesn't exist")
      rescue Exception => e
        raise e.message
      end
    end
  end

end
