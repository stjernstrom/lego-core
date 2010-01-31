class Lego::Config
  
  def load_global_options(parent)
    @__parent__ = parent
    instance_eval do
      def config
        @config ||= {}.merge(@__parent__.config.config)
      end
    end
  end
  
  def options(key)
    config[key.to_s]
  end
  
  def config
    @config ||= {}
  end
  
  def set(options={})
    options.keys.each do |key|
      config[key.to_s] = options[key]
    end
  end
end
