require File.join('spec', '/spec_helper')

describe Lego do

  context 'module' do
    it 'should contain a Controller Class' do
      Lego::Controller.should_not be_nil
    end

    it 'should have a plugin method to load plugins globally' do
      Lego.should respond_to(:plugin)
    end

    it 'should have a version' do
      Lego.version.should == Lego::VERSION.join('.')
    end
  end

  context '.plugin <plugin_module>' do
    it 'should call add_plugin on controller' do
      mymod = mock("MyModule")
      mymod.should_receive(:register).with(Lego::Controller)
      Lego.plugin mymod
    end

    context 'when plugin context is :controller' do
      it 'should be injected to Lego::Controller base' do
        module MyPlug
          def self.register(lego)
            lego.add_plugin :controller, self
          end
          def get_something; end
        end
        Lego::Controller.should_not respond_to(:get_something)
        Lego.plugin MyPlug
        create_new_app("MyApp1", Lego::Controller)
        create_new_app("MyApp2", Lego::Controller)
        MyApp1.should respond_to(:get_something)
      end

      after do
        rm_const "MyPlug", "MyApp1", "MyApp2"
      end
    end

    context 'when plugin context is :router' do
      it 'should be injected to Lego::Controller::RouteHandler base' do
        module GlobalPlug
          def self.register(lego)
            lego.add_plugin :router, self
          end

          def another_routehandler 
            add_route(:get, {})
          end

          def self.match_route(route, env); end
        end
        
        Object.const_set(:App1Plug, GlobalPlug.clone)
        Object.const_set(:App2Plug, GlobalPlug.clone)

        Lego.plugin GlobalPlug

        create_new_app("MyApp1", Lego::Controller)
        create_new_app("MyApp2", Lego::Controller)

        MyApp1.plugin App1Plug
        MyApp2.plugin App2Plug

Flytta till route hanlder, men minska nerh \r.....

        puts ""
        puts "MyApp1: #{MyApp1.object_id.to_s}"
        puts "MyApp2: #{MyApp2.object_id.to_s}"
        puts "Lego: #{Lego::Controller.object_id.to_s}"
        puts "MyApp1::RouteHandler: #{MyApp1::RouteHandler.object_id.to_s}"
        puts "MyApp2::RouteHandler: #{MyApp2::RouteHandler.object_id.to_s}"
        puts "Lego::Controller::RouteHandler: #{Lego::Controller::RouteHandler.object_id.to_s}"
        Lego::Controller::RouteHandler.matchers.should eql([GlobalPlug])
        MyApp1::RouteHandler.matchers.should eql([GlobalPlug, App1Plug])
        MyApp2::RouteHandler.matchers.should eql([GlobalPlug, App2Plug])
      end

      after do
        rm_const "GlobalPlug", "App1Plug", "App2Plug", "MyApp1", "MyApp2"
      end
    end
  end

end
