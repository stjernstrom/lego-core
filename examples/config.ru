require 'rubygems'
require File.join(Dir.pwd, 'lib', 'lego-core')

module MyPlugin
  def self.register(lego)
    lego.register_plugin :controller, BasicController
  end

  module BasicController
    def get(path, &block)
      routes.add :get, path, &block
    end
  end
end

module BasicRouter
  extend self

  def register(lego)
    lego.register_plugin :router, self
  end

  def match_route(route, path)
    route == path
  end

end

module InstanceVariableRouter
  extend self

  def register(lego)
    lego.register_plugin :router, self
  end

  attr_reader :match_data

  def match_route(route, path)
    matches = route.scan(/:([\w]+)/) 
    if matches.size > 0 
      exp = Regexp.escape( route ).gsub(/:([\w]+)/, "([\\w]+)") 
      if match = Regexp.new("^#{exp}$").match(path) 
        @match_data = {}
        1.upto(matches.size) do |i| 
          ivar_name = "@#{matches[i-1].to_s}".to_sym
          @match_data[ivar_name] = match.captures[i-1] 
        end 
        return true
      end 
    end 
    false
  end

  def prepare_context(context)
    context.action_ivars = match_data
  end
end

module ActionArgsRouter
  extend self

  def register(lego)
    lego.register_plugin :router, self
  end

  attr_reader :match_data

  def match_route(route, path)
    matches = route.scan(/:([\w]+)/) 
    if matches.size > 0 
      exp = Regexp.escape( route ).gsub(/:([\w]+)/, "([\\w]+)") 
      if match = Regexp.new("^#{exp}$").match(path) 
        @match_data = []
        1.upto(matches.size) do |i| 
          @match_data << match.captures[i-1] 
        end 
        return true
      end 
    end 
    false
  end

  def prepare_context(context)
    context.action_args = match_data
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

Lego.config do
  use BasicRouter
  set :foo => "bar"
end

class MyController < Lego::Controller
  use ViewPlugin
  use MyPlugin
  use InstanceVariableRouter
  use StupidMiddleware
  set :baz => "quux"
end

class MyApp < MyController

  get '/' do
    h("<html>root<html>")
  end

  get '/:name' do
    "#{@name.capitalize} says #{options(:baz)}!"
  end
end

class MyOtherApp < Lego::Controller
  use MyPlugin
  use ActionArgsRouter

  set :bar => "baz"

  get "/" do
    "{:foo => \"#{options(:foo)}\", :bar => \"#{options(:bar)}\"}"
  end

  get '/:name' do |name|
    "Hello #{name.capitalize}!"
  end
end

map '/' do
  run MyApp
end

map '/hello' do
  run MyOtherApp
end

