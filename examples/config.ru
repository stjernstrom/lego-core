require File.join(File.expand_path(File.dirname(__FILE__)), '..',  'lib', 'lego')

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

module SymbolExtractor
  def self.register(lego)
    lego.add_plugin :router, self 
  end

  def self.match_route(route, env) 
    return false if not route[:path].kind_of?(String)
    matches = route[:path].scan(/:([\w]+)/) 
    if matches.size > 0 
      exp = Regexp.escape( route[:path] ).gsub(/:([\w]+)/, "([\\w]+)") 
      if match = Regexp.new("^#{exp}$").match(env["PATH_INFO"]) 
        route[:instance_vars] = {} if route[:instance_vars].nil?  
        1.upto(matches.size) do |i| 
           route[:instance_vars][matches[i-1]] = match.captures[i-1] 
         end 
        return true   
      end 
    end 
    false 
  end 
end

module HtmlPlug
  def self.register(lego)
    lego.add_plugin :view, Mod
  end
  module Mod
    def h1(content)
      "<h1>#{content}</h1>"
    end
    def b(content)
      "<b>#{content}</b>"
    end
  end
end

class MyBlog < Lego::Controller
  set :foo => "bar"

  plugin BasicRoutes
  plugin RegexpMatcher
  plugin SymbolExtractor

  # Sample ActionContext plugin giving h1() and b() methods to views.
  plugin HtmlPlug

  #
  # Ex: http://localhost:9393/extract/something.jpg
  #
  get /extract\/(\w+)\.(\w+)/ do
    "We are extracting....#{@caps.inspect}" 
  end

  #
  # Ex: http://localhost:9393/
  #
  get '/' do
    "This is /"
  end

  get '/show/:id' do
    "This is show with id = #{@id}"
  end

  get '/options' do
    "foo => " + options(:foo)
  end

  #
  # Demonstrating a simple ActionContext plugin (HtmlPlug)
  # 
  # Ex: http://localhost:9393/viewplugins
  #
  get '/viewplugins' do
    h1("Hello, i'm a header.") + b("And im some stupid bold text.....")
  end

  #
  # This action will be called if no other route matches. 
  #
  # Ex: http://localhost:9393/you_will_not_find_me/
  #
  not_found do
    h1("404 - File not found") + "Lego could not find what you are looking for, sorry."
  end


end

run MyBlog

# Save this stuff to config.ru and fire it up with 'rackup'

