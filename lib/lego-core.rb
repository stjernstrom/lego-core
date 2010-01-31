$LOAD_PATH.unshift File.join(Dir.pwd, 'lib')
require 'rack'

module Lego
  require 'core-ext/object-ext.rb'
  require 'lego/utils/class-proxy'
  require 'lego/extension-handler'
  require 'lego/config'
  require 'lego/controller'
  require 'lego/controller/routes'
  require 'lego/controller/context'


  def self.config(&block)
    instance_eval(&block)
  end

  def self.set(options)
    Lego::Controller.instance.set(options)
  end

  def self.use(mod)
    Lego::Controller.use(mod)
  end
end
