require 'rails'

module EcoApps

  mattr_reader :master_url, :legal_ip
  mattr_accessor :current

  class << self

    def master_url=(master_url)
      if master_url.blank?
        raise 'Please set master_url in GEM_DIR/eco_apps/lib/platform_config.yml or APP_ROOT/config/app_config.yml!'
      end
      master_url =  master_url[Rails.env] if master_url.is_a?(Hash)
      if not master_url =~ Regexp.new("(http|https)://")
        raise 'master_url must begin with http:// or https://'
      end
      @@master_url = master_url
    end

    def legal_ip=(legal_ip)
      raise "legal_ip is not identified!" if legal_ip.blank?
      require 'netaddr'
      @@legal_ip = EcoApps::Util.convert_ip(legal_ip)
    end

    def in_master_app?
      current.in_master_app == true
    end

    def config_file
      Rails.root.join("config/app_config.yml")
    end

  end

  class App
    attr_reader :config

    def initialize(options = {})
      @config = options
    end

    def method_missing(method_name, *args)
      m = method_name.to_s
      if m != "url" and @config["api"].present? and @config["api"].keys.include?(m)
        @config["api"][m]
      else
        @config[m]
      end
    end

    def eco_apps_config
      @config.clone.extract!("name", "url", "api", "database")
    end

    class << self

      def cache_key
        "cached_config"
      end

      def read_cache(app_name)
        cache = YAML.load_file(EcoApps.config_file)[cache_key].try("[]", app_name.to_s)
        cache.blank? ? nil : cache.merge!("name" => app_name)
      end

      def write_cache(app_name, options)
        options.delete("name")
        edit_config_file do |config|
          config[cache_key] ||= {}
          config[cache_key][app_name] = options.merge!(config[cache_key][app_name]||{})
        end
      end

      def delete_cache(app_name)
        edit_config_file do |config|
          config[cache_key].delete(app_name) if config[cache_key].try("[]", app_name).present?
        end
      end

      private
      def edit_config_file(&block)
        config = YAML.load_file(EcoApps.config_file)
        block.call(config)
        File.open(EcoApps.config_file, 'w') {|f| f.write(config.to_yaml)}
      end
    end
  end

  class Railtie < Rails::Railtie
    initializer "copy_configuration_file" do
      EcoApps::Util.copy(File.join(File.dirname(__FILE__),"files/app_config.yml"), EcoApps.config_file, false)
    end

    initializer "set_configuration", :after => "copy_configuration_file" do
      configration = YAML.load_file(File.join(File.dirname(__FILE__), "../platform_config.yml"))
      configration.merge!(YAML.load_file(EcoApps.config_file)||{})

      EcoApps.master_url = configration["master_url"]
      EcoApps.legal_ip = configration["legal_ip"]

      EcoApps.current = EcoApps::App.new(configration.merge!(
          "name" => Rails.application.class.parent.to_s.tableize.singularize,
          "database" => YAML.load_file(Rails.root.join("config/database.yml"))))
    end

    initializer "reset_config", :after => "set_configuration" do
      MasterService.site = EcoApps.master_url
      MasterService.reset_config if Rails.env == "production"
    end
  end
end
