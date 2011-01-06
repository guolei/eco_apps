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
    end
  end
end
