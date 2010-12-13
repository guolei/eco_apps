module EcoApps
  class Util
    class << self
      def copy(src, dest, force = true)
        if not force and File.exist?(dest)
          return false
        else
          FileUtils.cp_r(src, dest)
          return true
        end
      end

      def convert_ip(ip_address)
        require 'netaddr'
        [ip_address].flatten.map{|ip|NetAddr::CIDR.create(ip)}
      end

      def encrypt(salt, raw_data)
        require 'openssl' unless defined?(OpenSSL)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, salt, raw_data.to_s)
      end

      def random_salt
        ActiveSupport::SecureRandom.hex(64)
      end
    end
  end
end
