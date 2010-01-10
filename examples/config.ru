require 'lego'

module BasicRoutes
  def self.register(lego)
    lego.add_plugin :controller, ControllerPlugin 
    lego.add_plugin :router, RouteMatcher 
  end

  module ControllerPlugin
    def get(path, &block)
      add_route(:get, { :path => path, :action_block => block })
    end
  end

  module RouteMatcher
    def self.match_route(route, env)
      (route[:path] == env['PATH_INFO']) ? true : false
    end
  end
end

module RegexpMatcher  
  def self.register(lego)
    lego.add_plugin :router, self 
  end

  def self.match_route(route, env)
    if route[:path].is_a?(Regexp) && match = route[:path].match(env['PATH_INFO'])
      route[:instance_vars] = { :caps => match.captures }
      true
    else
      false
    end
  end
end

class MyBlog < Lego::Controller

  plugin BasicRoutes
  plugin RegexpMatcher

  #
  # Ex: http://localhost:9393/extract/something.jpg
  #
  get /extract\/(.*)\.(.*)/ do
    "We are extracting....#{@caps.inspect}" 
  end

  #
  # Ex: http://localhost:9393/
  #
  get '/' do
    "This is /"
  end
end

run MyBlog

# Save this stuff to config.ru and fire it up with 'rackup'


