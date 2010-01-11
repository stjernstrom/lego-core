require File.join('spec', '/spec_helper')

describe Lego::Plugin::Controller::NotFound do

  it 'should register itself' do
    lego = mock('Lego')
    lego.should_receive('add_plugin').with(:controller, Lego::Plugin::Controller::NotFound)
    Lego::Plugin::Controller::NotFound.register(lego)
  end

  it 'should add a :not_found route to lego controller' do
    class TestPlugin
      extend Lego::Plugin::Controller::NotFound
    end
    block = lambda { "test" }
    TestPlugin.should_receive(:add_route).with(:not_found, { :set_response_code => 404, :action_block => block})
    TestPlugin.not_found(&block)
    rm_const 'TestPlugin'
  end

end

