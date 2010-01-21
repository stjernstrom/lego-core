require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rack/test'

context "LegoCore" do
  context "setup" do
    it "should define rack" do
      defined?(Rack).should eql("constant")
    end

    it "should define Lego" do
      defined?(Lego).should eql("constant")
    end

    it "should define Lego::Controller" do
      defined?(Lego::Controller).should eql("constant")
    end

    it "should define Lego::Controller::Context" do
      defined?(Lego::Controller::Context).should eql("constant")
    end
  end
end
