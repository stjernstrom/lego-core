require File.join(Dir.pwd, 'spec', 'spec_helper')

module BasicControllerExtension
  extend self

  def register(lego)
    lego.register_plugin :controller, BasicController
    lego.register_plugin :router, BasicRouter
  end

  module BasicController
    def get(path, &block)
      routes.add :get, path, &block
    end

    def post(path, &block)
      routes.add :get, path, &block
    end

    def put(path, &block)
      routes.add :get, path, &block
    end
    
    def delete(path, &block)
      routes.add :get, path, &block
    end
  end

  module BasicRouter
    def self.match_route(route, path)
      route == path
    end
  end
end

describe "Lego Controller Extension" do
  let(:env) { { 'PATH_INFO'=>'/', 'REQUEST_METHOD'=>'GET' } }

  describe "Defined on controller level" do

    before do
      Lego.use BasicControllerExtension
      @app = lego_app { get("/") { "foo" } }
    end

    it "should be available to subclasses" do
      @app.call(env)[2].body.should eql(["foo"])
    end
  end

  describe "Defined on app level" do

    before do
      @app1 = lego_app do 
        use BasicControllerExtension
        
        get("/") { "foo" }
      end
      
      @app2 = lego_app
    end

    it "should be available to the class that uses it" do
      @app1.call(env)[2].body.should eql(["foo"])
    end

    it "should not be available to other classes" do
      @app2.call(env)[2].should eql("404 - Not found")
    end
  end

  after do
    Lego::Controller.instance_variable_set(:@controller, nil)
  end
end
