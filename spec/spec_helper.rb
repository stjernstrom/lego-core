require 'rubygems'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lego-core'

def lego_app(superclass=Lego::Controller, &block)
  if block_given?
    Class.new(superclass, &block)
  else
    Class.new(superclass)
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

module BasicController
  extend self

  def register(lego)
    lego.register_plugin :controller, self
  end

  def get(path, &block)
    routes.add :get, path, &block
  end
end

module BasicView
  extend self

  def register(lego)
    lego.register_plugin :view, self
  end

  def greeting
    "greeting"
  end
end

class BasicMiddleware
  def initialize(app, options = {})
    @app = app
  end
 
  def call(env)         
    status, headers, body = @app.call(env)
    new_body = "Basic... "
    body.each { |str| new_body << str }
    new_body << " ...Middleware"    
   
    headers['Content-Length'] = new_body.length.to_s
 
    [status, headers, new_body]     
  end
end
