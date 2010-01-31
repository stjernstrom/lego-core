module ProxyMethods
  def proxy_methods(*names)
    names.each do |name|
      (class << self; self; end).instance_eval do
        define_method name do |*args|
          instance.send(name, *args)
        end
      end
    end
  end
end

Lego.extend ProxyMethods

class Lego::Controller
  extend ProxyMethods
end
