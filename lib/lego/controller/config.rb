module Lego::Controller::Config
  extend self
  
  def extended(mod)
    mod.instance_eval do
      def config
        @config ||= {}.merge(Lego::Controller::Config.config)
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
