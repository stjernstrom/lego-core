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

describe "Lego Configuration" do
  let(:env) { { 'PATH_INFO'=>'/', 'REQUEST_METHOD'=>'GET' } }

  describe "Defined on controller level" do

    before do
      Lego.use BasicRouter
      Lego.set :foo => "bar"
      @app = lego_app
      @app.instance.routes.add(:get, "/", &lambda { options :foo })
    end

    it "should be available to subclasses" do
      @app.call(env)[2].body.should eql(["bar"])
    end
  end

  describe "Defined on app level" do

    before do
      Lego.use BasicRouter
      @app1 = lego_app
      @app1.set :foo => "bar"
      @app1.instance.routes.add(:get, "/", &lambda { options :foo })
      
      @app2 = lego_app
      @app2.instance.routes.add(:get, "/", &lambda { options :foo })
    end

    it "should be available to the class that uses it" do
      @app1.call(env)[2].body.should eql(["bar"])
    end

    it "should not be available to other classes" do
      @app2.call(env)[2].body.should eql([""])
    end
  end

  after do
    Lego::Controller.instance_variable_set(:@controller, nil)
  end
end

