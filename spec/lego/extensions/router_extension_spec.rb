require File.join(Dir.pwd, 'spec', 'spec_helper')

module BasicRouter
  extend self

  def register(lego)
    lego.register_plugin :router, self
  end

  def match_route(route, path)
    route == path
  end
end

module InstanceVarsRouter
  extend self

  def register(lego)
    lego.register_plugin :router, self
  end

  def match_route(route, path)
    route == path
  end

  def prepare_context(context)
    context.action_ivars = {"@foo"=>'bar'}
  end
end

module ActionArgsRouter
  extend self

  def register(lego)
    lego.register_plugin :router, self
  end

  def match_route(route, path)
    route == path
  end

  def prepare_context(context)
    context.action_args = ['foo']
  end
end

describe "Lego Router Extension" do
  let(:env) { { 'PATH_INFO'=>'/', 'REQUEST_METHOD'=>'GET' } }

  describe "Defined on controller level" do

    before do
      Lego.use BasicRouter
      @app = lego_app
      @app.instance.routes.add(:get, "/", &lambda { "foo" })
    end

    it "should be available to subclasses" do
      @app.call(env)[2].body.should eql(["foo"])
    end
  end

  describe "Defined on app level" do

    before do
      @app1 = lego_app
      @app1.use BasicRouter
      @app1.instance.routes.add(:get, "/", &lambda { "foo" })
      
      @app2 = lego_app
      @app2.instance.routes.add(:get, "/", &lambda { "foo" })
    end

    it "should be available to the class that uses it" do
      @app1.call(env)[2].body.should eql(["foo"])
    end

    it "should not be available to other classes" do
      @app2.call(env)[2].should eql("404 - Not found")
    end
  end

  describe "Defining matches as instance variables" do
    before do
      Lego.use InstanceVarsRouter
      @app = lego_app
      @app.instance.routes.add(:get, "/", &lambda { @foo })
    end

    it "should make them available to actions" do
      @app.call(env)[2].body.should eql(["bar"])
    end
  end

  describe "Defining matches as action arguments" do
    before do
      Lego.use ActionArgsRouter
      @app = lego_app
      @app.instance.routes.add(:get, "/", &lambda { |foo| foo })
    end

    it "should make them available to actions" do
      @app.call(env)[2].body.should eql(["foo"])
    end
  end

  after do
    Lego::Controller.instance_variable_set(:@controller, nil)
  end
end
