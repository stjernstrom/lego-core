require File.join('spec', '/spec_helper')

describe Lego::Controller do

  it 'should contain an ActionContext Class' do
    Lego::Controller::ActionContext.should be_kind_of(Class)
  end

  it 'should contain an RouteHandler Module' do
    Lego::Controller::RouteHandler.should be_kind_of(Module)
  end

  context 'when inherited' do
    before do
      create_new_app("MyController", Lego::Controller)
    end

    it 'should create a new ActionContext for the inheriting class' do
      MyController::ActionContext.object_id.should_not == Lego::Controller::ActionContext.object_id
    end

    it 'should create a new RouteHandler for the inheriting class' do
      MyController::RouteHandler.object_id.should_not == Lego::Controller::RouteHandler.object_id
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

  context '.register :router, <plugin_module>' do
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

  context '.call <env> with a route that matches' do
    before do
      @env = ["Environment"]
      create_new_app("MyApp", Lego::Controller)
      MyApp::RouteHandler.should_receive(:match_all_routes).with(@env).and_return("route")
    end

    it 'should create a new instance of ActionContext' do
      mock = mock("ActionContext instance")
      mock.should_receive(:run).with("route", @env)
      MyApp::ActionContext.should_receive(:new).and_return(mock)
    end

    after do
      MyApp.call(@env)
      rm_const "MyApp"
    end
  end

  context '.call <env> with a route that don\'t matches' do
    before do
      @env = ["Environment"]
      create_new_app("MyApp", Lego::Controller)
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

