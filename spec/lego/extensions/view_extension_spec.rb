require File.join(Dir.pwd, 'spec', 'spec_helper')

module BasicViewExtension
  extend self

  def register(lego)
    lego.register_plugin :router, BasicRouter
    lego.register_plugin :view, BasicView
  end

  module BasicRouter
    def self.match_route(route, path)
      route == path
    end
  end

  module BasicView
    def foo
      "bar"
    end
  end
end

describe "Lego View Extension" do
  let(:env) { { 'PATH_INFO'=>'/', 'REQUEST_METHOD'=>'GET' } }

  describe "Defined on controller level" do

    before do
      Lego.use BasicViewExtension
      @app = lego_app
      @app.instance.routes.add(:get, "/", &lambda { foo })
    end

    it "should be available to subclasses" do
      @app.call(env)[2].body.should eql(["bar"])
    end
  end

  describe "Defined on app level" do

    before do
      @app1 = lego_app
      @app1.use BasicViewExtension
      @app1.instance.routes.add(:get, "/", &lambda { foo })
      
      @app2 = lego_app
      @app2.instance.routes.add(:get, "/", &lambda { foo })
    end

    it "should be available to the class that uses it" do
      @app1.call(env)[2].body.should eql(["bar"])
    end

    it "should not be available to other classes" do
      @app2.call(env)[2].should eql("404 - Not found")
    end
  end

  after do
    Lego::Controller.instance_variable_set(:@controller, nil)
  end
end
