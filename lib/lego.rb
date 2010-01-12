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
  autoload :Plugin,        'lego/plugin'

  def self.config(&block)
    class_eval &block
  end

  def self.set(options={})
    Lego::Controller.set options
  end
end
