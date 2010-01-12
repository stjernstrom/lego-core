require File.join('spec', '/spec_helper')

describe Lego do

  context 'module' do

    it 'should contain a Controller Class' do
      Lego::Controller.should_not be_nil
    end

    it 'should have a version' do
      Lego.version.should == Lego::VERSION.join('.')
    end

    it "should provide a global set" do
      Lego.set(:foo => "bar")
      Lego::Controller.current_config.config.should eql({"foo"=>"bar"})
    end

    it "should provide a global config" do
      Lego.config do
        set :foo => "bar"
        set :baz => "quux"
      end

      Lego::Controller.current_config.config.should eql({"foo"=>"bar","baz"=>"quux"})
    end

  end

end
