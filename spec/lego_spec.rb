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
          def get_something
            add_route(:get, { :path => '/global' })
          end
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
  end

end
