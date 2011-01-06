module ActiveResource
  class Base
    class << self
      alias_method :set_site, :site=

      def site=(site)
        if site.is_a?(Symbol) or site =~ /^[a-z_]+$/
          site = MasterService.app(site).url
        end
        set_site(site)
      end
    end
  end
end

