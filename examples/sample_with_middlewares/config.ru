require File.join(File.expand_path(Dir.pwd), 'lib', 'lego-core')

module SimpleRouter
  def self.register(lego)
    lego.add_plugin :router, RouteMatcher
    lego.add_plugin :controller, RouteHandler
  end

  module RouteHandler
    def get(path, &block)
      add_route(:get, {:path => path, :action_block => block})
    end
  end

  module RouteMatcher
    def self.match_route(route, env)
      (route[:path] == env['PATH_INFO']) ? [env, {}] : false
    end
  end
end

class StupidMiddleware
  def initialize(app, options = {})
    @app = app
  end

  def call(env)         
    status, headers, body = @app.call(env)
    new_body = "Stupid... "
    body.each { |str| new_body << str }
    new_body << " ...Middleware"    
   
    headers['Content-Length'] = new_body.length.to_s

    [status, headers, new_body]     
  end
end

Lego.plugin SimpleRouter

class MyApp < Lego::Controller
  use StupidMiddleware

  get "/" do
    "With middleware"
  end
end

class MyOtherApp < Lego::Controller

  get "/" do
    "Without middleware"
  end
end

map '/' do
  run MyApp
end

map '/other' do
  run MyOtherApp
end
