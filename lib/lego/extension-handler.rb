class Lego::ExtensionHandler

  attr_reader :middlewares

  def initialize(controller)
    @controller  = controller
    @middlewares = []
  end

  def use(plugin)
    if plugin.respond_to?(:register)
      plugin.register(self)
    elsif plugin.instance_methods.include?("call")
      middlewares.unshift(plugin)
    else
      raise "Unknown plugin type"
    end
  end

  def register_plugin(type, mod)
    send(type, mod)
  end

  def middleware_chain_for(app)
    middlewares.each do |middleware|
      app = middleware.new(app)
    end
    app
  end

  def load_global_middlewares(parent)
    parent.instance.extension_handler.middlewares.each do |middleware|
      middlewares.unshift middleware
    end
  end

  private

    def controller(mod)
      @controller.class.extend mod
    end

    def router(mod)
      @controller.routes.matchers << mod
    end

    def view(mod)
      @controller.context.send :include, mod
    end
end
