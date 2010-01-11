module Lego::Controller::Config
  extend self
  
  def extended(klass)
    klass.instance_eval do
      def config
        @config ||= {}.merge(Lego::Controller::Config.config)
      end
    end
  end
  
  def env
    @env ? @env.to_s : (ENV['RACK_ENV'] || 'development')
  end
  
  def environment(env=nil, &block)
    @env = env
    module_eval(&block)
  end
  
  def options(key)
    config[(ENV['RACK_ENV'] || 'development')][key.to_s]
  end
  
  def config
    @config ||= {}
  end
  
  def set(options={})
    config[env] = stringify_keys!(options.merge(config[env] ? config[env] : {}))
  end
  
  def stringify_keys!(hash)
    hash.keys.each do |key|
      hash[key.to_s] = hash.delete(key)
    end
    hash
  end
end
