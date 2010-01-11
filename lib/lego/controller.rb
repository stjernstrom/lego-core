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
      class_inheriting.const_set(:ActionContext, Class.new(Lego::Controller::ActionContext))
      class_inheriting.const_set(:RouteHandler,  Module).extend Lego::Controller::RouteHandler
      class_inheriting.const_set(:Config,        Module.new { extend Lego::Controller::Config })
    end

    # 
    # Use register inside your plugin to inject your code into the right place.
    #
    # Context available are:
    #
    # - :controller
    # - :router
    #
    # and on the way
    #
    # - :view
    # - :helper ?
    #

    def add_plugin(context, plugin_module)
      case context
      when :controller
        extend plugin_module
      when :router
        self::RouteHandler.add_matcher plugin_module 
      end
    end

    # 
    # add_route is exposed to your plugin as a shortcut for adding routes to the application they are plugged in to.
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

    def call(env)
      if route = self::RouteHandler.match_all_routes(env)
        self::ActionContext.new.run(route, env)
      else
        [404, {'Content-Type' => 'text/html'}, '404 - Not found'] 
      end
    end

  end

end
