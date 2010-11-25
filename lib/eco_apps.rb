require 'eco_apps/utils/common'
require 'eco_apps/master_service'

require 'eco_apps/initializer'

require 'eco_apps/utils/helpers'
require 'eco_apps/acts_as_readonly'
require 'eco_apps/extensions/active_resource'

ActionController::Base.send(:include, EcoApps::Helpers)
ActiveRecord::Base.send(:include, EcoApps::ActsAsReadonly)


