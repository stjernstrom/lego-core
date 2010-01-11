#
#:title:Lego-Core
#

module Lego

  file_path = File.expand_path( File.dirname(__FILE__) )
  $LOAD_PATH.unshift( file_path ) unless $LOAD_PATH.include?( file_path )

  VERSION = [0,0,1]

  #
  # Return the current Lego version.
  #

  def self.version
    VERSION.join(".")
  end

  #
  # plugin lets a plugin register itself globally
  #

  def self.plugin(plugin_module)
    plugin_module.register(Lego::Controller)
  end

  autoload :Controller,    'lego/controller'
  autoload :Plugin,        'lego/plugin'

end
