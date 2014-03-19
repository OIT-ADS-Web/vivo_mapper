require 'java'
require "vivo_mapper/version"

vivo_mapper = File.expand_path("../vivo_mapper",__FILE__)

# TODO: Should no longer be necessary now we are using jbundler.
# Don't load jars if we are in torquebox.
unless ENV.has_key?('TORQUEBOX_APP_NAME')
  Dir.glob("#{vivo_mapper}/javalib/**/*.jar") {|file| require file}
end

require 'vivo_mapper/config'
require 'vivo_mapper/managers/import_manager'
require 'vivo_mapper/mappable_resource'
