require 'rubygems'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lego-core'

def lego_app(superclass=Lego::Controller, &block)
  if block_given?
    Class.new(superclass, &block)
  else
    Class.new(superclass, &block)
  end
end

module BasicRouter
  def self.register(lego)
    lego.register_plugin :router, self
  end

  def self.match_route(route, path)
    route == path
  end
end
