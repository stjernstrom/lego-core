class Lego::Controller
  proxy_methods :call, :use, :routes, :config, :set

  def self.instance
    @controller ||= self.new
  end

  def self.inherited(subclass)
    subclass.inherit_constants(self)
    subclass.load_globals(self)
  end

  def self.inherit_constants(parent)
    self.const_set(:Context, Class.new(parent::Context))
    self::Context.const_set(:CurrentClass, self)
  end

  def self.load_globals(parent)
    self.routes.load_global_matchers(parent)
    self.config.load_global_options(parent)
    self.instance.extension_handler.load_global_middlewares(parent)
  end
  
  attr_reader :routes, :config

  def context
    self.class::Context
  end

  def extension_handler
    @extension_handler ||= ::Lego::ExtensionHandler.new(self)
  end

  def initialize
    @routes = Routes.new
    @config = ::Lego::Config.new
  end

  def use(plugin)
    extension_handler.use(plugin)
  end

  def set(options)
    config.set(options)
  end

  def call(env)
    app = lambda do |env|
      verb, path = extract_method_and_path(env)

      routes.match(verb, path) do |match|
        @context = context.new
        
        if (matcher = match[:matcher]).respond_to? :prepare_context
          matcher.prepare_context(@context) 
        end

        @context.finish(env, &match[:action])
      end
    end
    
    extension_handler.middleware_chain_for(app).call(env)
  end
  
  private

    def extract_method_and_path(env)
      [env["REQUEST_METHOD"].downcase.to_sym, env["PATH_INFO"]]
    end
end
