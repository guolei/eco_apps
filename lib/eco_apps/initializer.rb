require 'rails'

module EcoApps

  class Railtie < Rails::Railtie
    initializer "copy_configuration_file" do
      EcoApps::Util.copy(File.join(File.dirname(__FILE__),"files/app_config.yml"), EcoApps::App.config_file, false)
    end

    initializer "set_configuration", :after => "copy_configuration_file" do
      configration = YAML.load_file(EcoApps.config_file)
      configration.merge!(YAML.load_file(EcoApps::App.config_file)||{})

      EcoApps.current = EcoApps::App.new(configration.merge!(
          "name" => Rails.application.class.parent.to_s.tableize.singularize,
          "database" => YAML.load_file(Rails.root.join("config/database.yml"))))

      EcoApps.validate_master_app_url! 
      EcoApps.validate_legal_ip!
    end

    initializer "reset_config", :after => "set_configuration" do
      MasterService.site = EcoApps.master_app_url
      MasterService.reset_config if Rails.env == "production"
    end
  end
end
