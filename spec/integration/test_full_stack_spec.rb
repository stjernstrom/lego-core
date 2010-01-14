require File.join('spec', '/spec_helper')

describe 'Full stack request' do

  context 'with no routes specified' do
    before do
      reset_lego_base
      class MyApp < Lego::Controller; end
      rack_env = {
      'PATH_INFO' => '/' ,
      'REQUEST_METHOD' => 'GET'
      }
      @result = MyApp.call(rack_env)
    end

    it 'should respond with a valid 404 response' do
      @result[0].should eql(404)
      @result[1].should eql({"Content-Type"=>"text/html"})
      @result[2].should eql('404 - Not found')
    end

    after do
      rm_const 'MyApp'
    end
  end

  context 'with global plugins' do
    before do

      reset_lego_base

      module GlobalPlugin
        def self.register(lego)
          lego.add_plugin :view, View
          lego.add_plugin :router, Matcher
          lego.add_plugin :controller, Routes
        end
        module View
          def h1(content)
            "<h1>#{content}</h1>"
          end
        end
        module Routes
          def get(path, &block)
            add_route(:get, {:path => path, :action_block => block})

          end
        end
        module Matcher
          def self.match_route(route, env)
            match_data = { :instance_vars => { :foo => "bar" }}
            (route[:path] == env['PATH_INFO']) ? [env, match_data] : false
          end
        end
      end

      Lego.plugin GlobalPlugin

      class App1 < Lego::Controller
        get '/hello' do
          h1 "Hello world, #{@foo}"
        end
      end

      rack_env = {
      'PATH_INFO' => '/hello' ,
      'REQUEST_METHOD' => 'GET'
      }
      @result = App1.call(rack_env)
    end

    it 'should respond with with valid data' do
      @result[0].should eql(200)
      @result[1].should eql({"Content-Type"=>"text/html"})
      @result[2].should eql('<h1>Hello world, bar</h1>')
    end

    after do
      rm_const 'App1', 'App2'
    end
  end

  context 'using middlewares' do
    before do
      Lego::Controller.middlewares.clear

      reset_lego_base

      module GlobalPlugin
        def self.register(lego)
          lego.add_plugin :router, Matcher
          lego.add_plugin :controller, Routes
        end
        module Routes
          def get(path, &block)
            add_route(:get, {:path => path, :action_block => block})
          end
        end
        module Matcher
          def self.match_route(route, env)
            match_data = { :instance_vars => { :foo => "bar" }}
            (route[:path] == env['PATH_INFO']) ? [env, match_data] : false
          end
        end
      end

      Lego.plugin GlobalPlugin

      class App1 < Lego::Controller
        use StupidMiddleware

        get '/hello' do
          "Hello world"
        end
      end

      class App2 < Lego::Controller

        get '/hello' do
          "Hello world"
        end
      end

      rack_env = {
      'PATH_INFO' => '/hello' ,
      'REQUEST_METHOD' => 'GET'
      }
      @app1_result = App1.call(rack_env)
      @app2_result = App2.call(rack_env)
    end

    it 'should be manipulated by the middleware' do
      @app1_result[0].should eql(200)
      @app1_result[1].should eql({"Content-Type"=>"text/html","Content-Length"=>"35"})
      @app1_result[2].should eql('Stupid... Hello world ...Middleware')
    end

    it 'should not be manipulated by the middleware' do
      @app2_result[0].should eql(200)
      @app2_result[1].should eql({"Content-Type"=>"text/html"})
      @app2_result[2].should eql('Hello world')
    end

    after do
      rm_const 'App1', 'App2'
    end
  end

  context 'using global middlewares' do
    before do

      reset_lego_base

      module GlobalPlugin
        def self.register(lego)
          lego.add_plugin :router, Matcher
          lego.add_plugin :controller, Routes
        end
        module Routes
          def get(path, &block)
            add_route(:get, {:path => path, :action_block => block})
          end
        end
        module Matcher
          def self.match_route(route, env)
            match_data = { :instance_vars => { :foo => "bar" }}
            (route[:path] == env['PATH_INFO']) ? [env, match_data] : false
          end
        end
      end

      Lego.plugin GlobalPlugin
      Lego::Controller.use StupidMiddleware

      class App1 < Lego::Controller

        get '/hello' do
          "Hello world"
        end
      end

      class App2 < Lego::Controller

        get '/hello' do
          "Hello world"
        end
      end

      rack_env = {
      'PATH_INFO' => '/hello' ,
      'REQUEST_METHOD' => 'GET'
      }
      @app1_result = App1.call(rack_env)
      @app2_result = App2.call(rack_env)
    end

    it 'should be manipulated by the middleware' do
      @app1_result[0].should eql(200)
      @app1_result[1].should eql({"Content-Type"=>"text/html","Content-Length"=>"35"})
      @app1_result[2].should eql('Stupid... Hello world ...Middleware')
    end

    it 'should also be manipulated by the middleware' do
      @app2_result[0].should eql(200)
      @app2_result[1].should eql({"Content-Type"=>"text/html","Content-Length"=>"35"})
      @app2_result[2].should eql('Stupid... Hello world ...Middleware')
    end

    after do
      Lego::Controller.middlewares.clear
      App1.middlewares.clear
      App2.middlewares.clear
      rm_const 'App1', 'App2'
    end
  end
end
