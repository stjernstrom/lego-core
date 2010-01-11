#
# = Lego::Controller
# Lego::Controller is the context where you setup routes and stuff.
#

class Lego::Controller

  autoload :ActionContext, 'lego/controller/action_context'
  autoload :RouteHandler,  'lego/controller/route_handler'
  autoload :Config,        'lego/controller/config'

  class << self

    #
    # When Lego::Controller is inherited it will create a new Lego::Controller::ActionContext for the class thats inheriting
    # and it will also create a new Lego::Controller::RouteHandler module for the class thats inheriting. 
    #

    def inherited(class_inheriting)
      class_inheriting.const_set(:ActionContext, Class.new(Lego::Controller::ActionContext) do
        const_set :ApplicationClass, class_inheriting
      end)
      class_inheriting.const_set(:RouteHandler,  Lego::Controller::RouteHandler.clone)
      class_inheriting.const_set(:Config,        Module.new { extend Lego::Controller::Config })
    end

    # 
    # Use register inside your plugin to inject your code into the right place.
    #
    # Context available are:
    #
    # - :controller
    # - :router
    # - :view
    #
    # and on the way
    #
    # - :helper ?
    #

    def add_plugin(context, plugin_module)
      base = (self == Lego::Controller) ? Lego::Controller : self 
      case context
      when :controller
        base.extend plugin_module
      when :router
        base::RouteHandler.add_matcher plugin_module 
      when :view
        self::ActionContext.instance_eval do
          include plugin_module
        end
      end
    end

    # 
    # add_route <method> <route> is exposed to your plugin as a shortcut for adding routes to the application they are plugged in to.
    # 
    # <method> is a symbol for the request method it should match
    # 
    # Valid options are:
    #
    # - :get
    # - :post
    # - :put
    # - :head
    # - :options
    # - :not_found
    #
    # <route> is a hash with keys to be handled by the route matchers and also the ActionContext
    #
    # Valid options are anything your route matcher can handle. But there's some keys that's special for Lego and they are.
    #
    # - :action_block      => A block thats going to be executed inside ActionContext.
    # - :instance_vars     => A hash where the keys beeing converted to ActionContext vars ex: { :var1 => "value1", :var2 => "value2" } 
    # - :set_response_code => An integer representing the response code.
    #

    def add_route(method, route)
      self::RouteHandler.add_route(method, route)
    end

    #
    # Use plugin in your controllers to choose which extensions you want to use in this controller. 
    #
    # Extensions then inject themself into the right context.
    #

    def plugin(plugin_module)
      plugin_module.register(self)
    end

    #
    # Provides acces to the current Config class
    #

    def current_config
      self::Config
    end

    #
    # Use set to define environment agnostic configuration options
    #
    # Usage:
    #   Lego::Controller.set :foo => "bar"
    #

    def set(options={})
      current_config.set(options)
    end

    #
    # Use environment to define environment specific configuration options 
    #
    # Usage:
    #   Lego::Controller.environment :development do
    #     set :foo => "bar"
    #   end
    #
    # or set environment agnostic configuration options by leaving out the environment parameter
    #
    # Usage:
    #   Lego::Controller.environment do
    #     set :foo => "bar"
    #   end
    #

    def environment(env=nil, &block)
      raise ArgumentError, "No block provided" unless block_given?
      current_config.environment(env, &block)
    end

    #
    # call is used to handle an incomming Rack request. 
    #
    # If no matching route is found we check for a defined :not_found route
    # and if no :not_found defined we send a simple 404 - not found.
    #

    def call(env)
      if route = self::RouteHandler.match_all_routes(env)
        self::ActionContext.new.run(route, env)
      else
        if route = self::RouteHandler.routes[:not_found]
          self::ActionContext.new.run(route, env)
        else
          [404, {'Content-Type' => 'text/html'}, '404 - Not found'] 
        end
      end
    end

  end

  #
  # Core plugins
  #

  plugin Lego::Plugin::Controller::NotFound

end
