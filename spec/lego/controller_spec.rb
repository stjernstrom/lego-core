require File.join('spec', '/spec_helper')

describe Lego::Controller do

  it 'should contain an ActionContext Class' do
    Lego::Controller::ActionContext.should be_kind_of(Class)
  end

  it 'should contain an RouteHandler Module' do
    Lego::Controller::RouteHandler.should be_kind_of(Module)
  end

    it 'should load Lego::Plugin::Controller::NotFound by default' do
      Lego::Controller.methods.should include('not_found')
    end

  context 'when inherited' do
    before do
      create_new_app("MyController", Lego::Controller)
    end

    it 'should create a new ActionContext for the inheriting class' do
      MyController::ActionContext.object_id.should_not == Lego::Controller::ActionContext.object_id
    end

    it 'should setup a constant on ActionContext holding a reference to the application class' do
      MyController::ActionContext::ApplicationClass.should eql(MyController)
    end

    it 'should create a new RouteHandler for the inheriting class' do
      MyController::RouteHandler.object_id.should_not == Lego::Controller::RouteHandler.object_id
    end

    it 'should create a new Config for the inheriting class' do
      MyController::Config.object_id.should_not == Lego::Controller::Config.object_id
    end

    it 'should create a new Config for every inheriting class' do
      create_new_app "MyOtherController", Lego::Controller
      MyController::Config.object_id.should_not == MyOtherController::Config.object_id
    end
  end

  context '.plugin <plugin_module>' do
    before do
      create_new_app("MyApp", Lego::Controller)
      module MyPlugin
        def self.register(lego)
          lego.register self
        end
      end
    end

    after do
      rm_const "MyPlugin", "MyApp"
    end

    it 'should have a class method named plugin' do
      MyApp.should respond_to(:plugin)
    end

    it 'should call self.register on <plugin_module>' do
      MyPlugin.should_receive(:register).with(MyApp)
      MyApp.plugin MyPlugin
    end
  end

  context '.add_plugin :view, <plugin_module>' do
    before do
      create_new_app("MyApp", Lego::Controller)
      module MyViewPlugin
        def self.register(lego)
          lego.add_plugin :view, self
        end
        def makebold(content)
          "<b>#{content}</b>"
        end
      end
    end

    it 'should make plugin methods availibe to ActionContext' do
      MyApp::ActionContext.instance_methods.should_not include('makebold')
      MyApp.plugin MyViewPlugin
      MyApp::ActionContext.instance_methods.should include('makebold')
    end

    after do
      rm_const "MyViewPlugin", "MyApp"
    end
  end

  context '.add_plugin :controller, <plugin_module>' do
    before do
      create_new_app("MyApp", Lego::Controller)
      module MyPlugin2
        def self.register(lego)
          lego.add_plugin :controller, PluginMethods
        end
        module PluginMethods
          def get_this;end
        end
      end
    end

    after do
      rm_const "MyPlugin2", "MyApp"
    end

    it 'should extend controller with <plugin_module>' do
      MyApp.should_not respond_to(:get_this)
      MyApp.plugin MyPlugin2
      MyApp.should respond_to(:get_this)
    end
  end

  context '.add_route <method> <route>' do
    before do
      create_new_app("MyApp", Lego::Controller)
    end

    it 'should be defined' do
      MyApp.should respond_to(:add_route)
    end

    it 'should add a route to RouteHandler' do
      route = {:path => '/somewhere'}
      method = :get
      MyApp::RouteHandler.should_receive(:add_route).with(method, route)
      MyApp.add_route(method, route)
    end
    after { rm_const 'MyApp' }
  end

  context '.add_plugin :router, <plugin_module>' do
    before do
      create_new_app("MyApp", Lego::Controller)
      module MyRouter
        def self.register(lego)
          lego.add_plugin :router, RouterMethods 
        end
        module RouterMethods
          extend self
          def match_route
          end
        end
      end
    end

    after do
      rm_const "MyRouter", "MyApp"
    end

    it 'should not extend controller with <plugin_module>' do
      MyApp.plugin MyRouter
      MyApp.should_not respond_to(:match_route)
    end

    it 'should call add_matcher on RouteHandler with <plugin_module>' do
      MyApp::RouteHandler.should_receive(:add_matcher).with(MyRouter::RouterMethods)
      MyApp.plugin MyRouter
    end
  end

  context '.call <env>' do
    context 'with a route that matches' do
      before do
        @env = ["Environment"]
        @match_data = [:foo => "bar"]
        @match_route = [:route => "route"]
        create_new_app("MyApp", Lego::Controller)
        Lego::Controller.middlewares.clear
        MyApp::RouteHandler.should_receive(:match_all_routes).with(@env).and_return([@match_route, @env, @match_data])
      end

      it 'should create a new instance of ActionContext' do
        mock = mock("ActionContext instance")
        mock.should_receive(:run).with([@match_route, @env, @match_data])
        MyApp::ActionContext.should_receive(:new).and_return(mock)
      end

      after do
        MyApp.call(@env)
        rm_const "MyApp"
      end
    end

    context 'without a route match and a not_found route defined' do
      before do
        @env = []
        @block = lambda { "404, gone." } 
        create_new_app("MyApp", Lego::Controller)
        Lego::Controller.middlewares.clear
        MyApp::RouteHandler.should_receive(:match_all_routes).with(@env).and_return(nil)
        MyApp::RouteHandler.should_receive('routes').and_return({:not_found => { :action_block => @block }})
      end

      it 'should get a valid 404 response with the block data' do
        MyApp.call(@env).should eql(
          [404, {'Content-Type' => 'text/html'}, '404, gone.']
        )
      end

      after do
        rm_const "MyApp"
      end
    end

    context 'with a route that don\'t matches' do
      before do
        @env = ["Environment"]
        create_new_app("MyApp", Lego::Controller)
        Lego::Controller.middlewares.clear
        MyApp::RouteHandler.should_receive(:match_all_routes).with(@env).and_return(nil)
      end

      it 'should create a new instance of ActionContext' do
        MyApp::ActionContext.should_not_receive(:new)
      end

      after do
        MyApp.call(@env).should eql(
          [404, {'Content-Type' => 'text/html'}, '404 - Not found']
        )
        rm_const "MyApp"
      end
    end

  end

  context ".set" do
    context 'on Lego::Controller' do

      it "should proxy the method call to its own Config" do
        Lego::Controller::Config.should_receive(:set).and_return(nil)
        Lego::Controller.set :foo => "bar"
      end
    end

    context "on subclasses" do
      
      before do
        create_new_app "MyApp", Lego::Controller
      end

      it "should proxy the method call to its own Confg" do
        MyApp::Config.should_receive(:set).and_return(nil)
        MyApp.set :foo => "bar"
      end

      after do
        rm_const "MyApp"
      end
    end
  end

  context ".use <middleware>" do
    before do
      class Middleware1;end
      class Middleware2;end

      Lego::Controller.middlewares.clear
    end

    it "should add the middleware to the current contexts middlewares collection" do
      Lego::Controller.use Middleware1
      Lego::Controller.middlewares.should eql([Middleware1])
    end

    it "should add the middlewares in the reverse order" do
      Lego::Controller.use Middleware1
      Lego::Controller.use Middleware2
      Lego::Controller.middlewares.should eql([Middleware2, Middleware1])
    end

    after do
      Lego::Controller.middlewares.clear
      rm_const "Middleware1", "Middleware2", "Controller"
    end
  end

  context ".middlewares reader method" do

    before do
      Lego::Controller.middlewares.clear
    end

    it "should return an empty array when no middlewares are used" do
      Lego::Controller.middlewares.should eql([])
    end
  end
end

