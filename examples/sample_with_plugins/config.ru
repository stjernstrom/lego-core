require 'rubygems'
require 'lego-modules'
require 'lego-core'
require 'erb'

# Global options
Lego.config do
  plugin SimpleRouter
  set :views => "./"
end

class MyApp < Lego::Controller

  # Load our Erb plugin for this controller.
  plugin ViewHelpers

  get '/' do
    redirect_to '/hello'
  end

  get '/hello' do
    # Setup a instance var for our template to use...
    @title = "Hello, right now it's:"
    # Render our ERB template hello.erb found in the templates folder.
    @userinput = "<b>hello bold</b>"
    erb :hello
  end

end

# Makes Rack run our app
run MyApp
