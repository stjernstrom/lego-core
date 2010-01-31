require File.join(Dir.pwd, 'spec', 'spec_helper')

describe "Lego::Controller" do
  it "should respond to call" do
    Lego::Controller.should respond_to(:call)
  end

  it "should respond to use" do
    Lego::Controller.should respond_to(:use)
  end

  it "should respond to routes" do
    Lego::Controller.should respond_to(:routes)
  end

  it "should respond to config" do
    Lego::Controller.should respond_to(:config)
  end

  it "should respond to set" do
    Lego::Controller.should respond_to(:set)
  end

  describe "instance" do
    it "should respond to call" do
      Lego::Controller.instance.should respond_to(:call)
    end

    it "should respond to use" do
      Lego::Controller.instance.should respond_to(:use)
    end

    it "should respond to routes" do
      Lego::Controller.instance.should respond_to(:routes)
    end

    it "should respond to config" do
      Lego::Controller.instance.should respond_to(:config)
    end

    it "should respond to set" do
      Lego::Controller.instance.should respond_to(:set)
    end
  end

  describe "subclass" do

    before do
      @app1 = lego_app
      @app2 = lego_app
    end

    it "should have a unique instance" do
      @app1.instance.should_not eql(@app2.instance)
    end

    it "should not share instance with controller" do
      @app1.instance.should_not eql(Lego::Controller.instance)
    end

    it "should only have one instance" do
      @app1.instance.should eql(@app1.instance)
    end
  end
end
