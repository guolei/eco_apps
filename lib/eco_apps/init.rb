require 'rails'

module EcoApps
  class << self
    def master_url
      @@master_url ||= ""
    end

    def master_url=(master_url)
      if master_url.blank?
        raise 'Please set master_url in GEM_DIR/eco_apps/lib/platform_config.yml or APP_ROOT/config/app_config.yml!'
      end
      master_url =  master_url[Rails.env] if master_url.is_a?(Hash)
      if not master_url =~ Regexp.new("http://")
        raise 'master_url must begin with http://'
      end
      @@master_url = master_url
    end

    def legal_ip
      @@legal_ip ||= []
    end

    def legal_ip=(legal_ip)
      raise "legal_ip is not identified!" if legal_ip.blank?
      require 'netaddr'
      @@legal_ip = [legal_ip].flatten.map{|ip|NetAddr::CIDR.create(ip)}
    end

    def in_master_app?
      @@in_master_app ||= false
    end

    def in_master_app=(in_or_not)
      @@in_master_app = in_or_not
    end
  end

  module App
    class << self
      def name
        Rails.application.class.parent.to_s.tableize.singularize
      end

      def configuration
        @@configuration ||= {}
      end

      def configuration=(configuration)
        @@configuration = configuration
      end

      def method_missing(method_name, *args)
        configuration[method_name] || super
      end
    end
  end

  class Railtie < Rails::Railtie
    initializer "copy_configuration_file" do
      EcoApps::Util.copy(File.join(File.dirname(__FILE__),"files/app_config.yml"), Rails.root.join("config/app_config.yml"), false)
    end

    initializer "set_configuration", :after => "copy_configuration_file" do
      configration = YAML.load_file(File.join(File.dirname(__FILE__), "../platform_config.yml"))
      configration.merge!(YAML.load_file(Rails.root.join("config/app_config.yml")))

      EcoApps.master_url = configration["master_url"]
      EcoApps.legal_ip = configration["legal_ip"]
      EcoApps::App.configuration = configration.with_indifferent_access
    end

    initializer "reset_config", :after => "set_configuration" do
      CoreService.reset_config unless Rails.env == "test"
    end
  end
end
