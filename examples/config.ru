require 'rubygems'
require File.join(Dir.pwd, 'lib', 'lego-core')

module MyPlugin
  def self.register(lego)
    lego.register_plugin :controller, BasicController
    lego.register_plugin :router,     BasicRouter
  end

  module BasicController
    def get(path, &block)
      routes.add :get, path, &block
    end
  end

  module BasicRouter
    def self.match_route(routes, verb, path)
      routes[verb][path]
    end
  end
end

module ViewPlugin
  def self.register(lego)
    lego.register_plugin :view, self
  end

  def h(content)
    Rack::Utils.escape(content)
  end
end

Lego::Controller.plugin MyPlugin

class MyApp < Lego::Controller
  plugin ViewPlugin

  get '/' do
    h("<html>root<html>")
  end
end

run MyApp

