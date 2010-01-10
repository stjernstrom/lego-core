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

  autoload :Controller,    'lego/controller'

end
