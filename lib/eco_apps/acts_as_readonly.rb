module EcoApps
  module ActsAsReadonly
    def self.included(base)
      base.extend(ClassMethods)
    end
 
    module ClassMethods
      def acts_as_readonly(name, options = {})
        cattr_accessor :app_name
        self.app_name = name

        tbn = options[:table_name] || self.table_name

        if Rails.env == "test" and use_cache_table?(tbn)
          generate_table_for_test(tbn)
        else
          config = options[:database] || MasterService.app(name).database
          config = YAML.load(config) if config.is_a?(String)
          self.establish_connection(config[Rails.env] || config)  #activate readonly connection

          self.set_table_name tbn
          self.table_name_prefix = self.connection.current_database + "."

          unless options[:readonly]==false or Rails.env == "test"
            include EcoApps::ActsAsReadonly::InstanceMethods
            extend EcoApps::ActsAsReadonly::SingletonMethods
          end
        end
        
      end
      alias_method :acts_as_remote, :acts_as_readonly

      private
      def use_cache_table?(table_name)
        EcoApps.current.readonly_for_test.try("[]", table_name).present?
      end

      def generate_table_for_test(table_name)
        begin
          self.connection.create_table(self.table_name, :force => true){|f|
            config = EcoApps.current.readonly_for_test[table_name]
            config.each{|key, value|
              f.send(key, *(value.is_a?(Array) ? value.join(",") : value.gsub(" ","").split(",")))
            }
            f.timestamps
          }
        rescue Exception => e
          puts "#{e.message} error occured in #{table_name}"
        end
      end
    end

    module SingletonMethods
      def delete_all(conditions = nil)
        raise ActiveRecord::ReadOnlyRecord
      end
    end

    module InstanceMethods
      def readonly?
        true
      end

      def destroy
        raise ActiveRecord::ReadOnlyRecord
      end
    end
  
  end
end
 
