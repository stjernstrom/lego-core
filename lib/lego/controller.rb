class Lego::Controller
  def self.controller_instance
    @controller ||= self.new
  end

  def self.inherited(subclass)
    subclass.const_set(:Context, Class.new(Context))
  end

  def self.plugin(mod)
    controller_instance.plugin(mod)
  end

  def self.register_plugin(type, mod)
    controller_instance.register_plugin(type, mod)
  end

  def self.call(env)
    controller_instance.call(env)
  end

  def self.routes
    controller_instance.routes
  end

  def self.context
    controller_instance.context
  end

  attr_reader :routes, :context

  def current_context
    self.class::Context
  end

  def current_routes
    self.class::Routes
  end

  def initialize
    @routes = current_routes.new
    unless self.class == Lego::Controller
      @routes.matchers << Lego::Controller.controller_instance.routes.matchers
      @routes.matchers.flatten!
    end
  end

  def plugin(mod)
    mod.register(self)
  end

  def register_plugin(type, mod)
    send(type, mod)
  end

  def call(env)
    verb = env["REQUEST_METHOD"].downcase.to_sym
    path = env["PATH_INFO"]

    if action = routes.get(verb, path)
      @context = current_context.new
      @context.finish(env, &action)
    else
      route_not_found
    end
  end

  
  private

    def controller(mod)
      self.class.extend mod
    end

    def router(mod)
      routes.matchers << mod
    end

    def view(mod)
      current_context.send :include, mod
    end

    def route_not_found
      [
        404, {
          'Content-Type'   =>'text/html', 
          'Content-Length' =>'9'
        }, ["Not Found"]
      ]
    end
end
