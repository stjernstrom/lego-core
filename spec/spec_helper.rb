$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'lib/lego'
require 'spec'

def create_new_app(class_name, baseclass = Class)
  Object.class_eval do
    remove_const class_name.to_sym if const_defined? class_name
  end
  Object.const_set(class_name.to_sym, Class.new(baseclass))
end

def rm_const(*const_name)
  const_name = [const_name] if const_name.kind_of?(String)
  Object.class_eval do
    const_name.each do |constant|
      remove_const constant.to_sym if const_defined? constant
    end
  end
end

