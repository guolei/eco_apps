module ActiveResource
  class Base
    class << self
      alias_method :set_site, :site=

      def site=(site)
        site = MasterService.app(site).url if site.is_a?(Symbol)
        set_site(site)
      end
    end
  end
end

