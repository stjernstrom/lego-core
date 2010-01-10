require File.join('spec', '/spec_helper')

describe Lego do

  context 'module' do

    it 'should contain a Controller Class' do
      Lego::Controller.should_not be_nil
    end

    it 'should have a version' do
      Lego.version.should == Lego::VERSION.join('.')
    end

  end

end
