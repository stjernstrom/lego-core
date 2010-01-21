class Lego::Controller
  def self.controller_instance
    @controller ||= self.new
  end

  def self.method_added(name)
    metaclass = class << self; self; end
    metaclass.send :define_method, name do |*args, &block|
      controller_instance.send(name, *args, &block) 
    end
  end

  def self.inherited(subclass)
    subclass.const_set(:Context, Class.new(Context))
  end

  attr_reader :routes, :context

  def initialize
    @routes = Routes.new
    unless self.class == Lego::Controller
      @routes.matchers << Lego::Controller.controller_instance.routes.matchers.flatten
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
      @context = Context.new
      @context.finish(env, &action)
    else
      route_not_found
    end
  end

  
  private

    def controller(mod)
      self.class.extend mod
    end

    def helper(mod)
      Context.send :include, mod
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
