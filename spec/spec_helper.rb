$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'lib/lego-core'
require 'spec'

def create_new_app(class_name, baseclass = Class)
  Object.class_eval do
    remove_const class_name.to_sym if const_defined? class_name
  end
  Object.const_set(class_name.to_sym, Class.new(baseclass))
end

def rm_const(*const_name)
  const_name = [const_name] if const_name.kind_of?(String)
  Object.class_eval do
    const_name.each do |constant|
      remove_const constant.to_sym if const_defined? constant
    end
  end
end

def reset_lego_base
  return if not Object.const_defined? :Lego 
  Lego.class_eval do
    Lego::Controller.class_eval do
      remove_const :RouteHandler if const_defined? :RouteHandler
      remove_const :ActionContext if const_defined? :ActionContext
    end
    remove_const :Controller if const_defined? :Controller
  end
  Object.class_eval do
    remove_const :Lego  
  end
  load 'lib/lego-core.rb'
  load 'lib/lego/plugin.rb'
  load 'lib/lego/plugin/controller/not_found.rb'
  load 'lib/lego/controller.rb'
  load 'lib/lego/controller/route_handler.rb'
  load 'lib/lego/controller/action_context.rb'
  load 'lib/lego/controller/config.rb'
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
