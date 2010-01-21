$LOAD_PATH.unshift File.join(Dir.pwd, 'lib')
require 'rack'

module Lego
  require 'lego/controller'
  require 'lego/controller/context'
  require 'lego/controller/routes'
end
