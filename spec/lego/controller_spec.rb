require File.join(Dir.pwd, 'spec', 'spec_helper')

describe "Lego::Controller" do
  before do
    @env = {'REQUEST_METHOD'=>'GET','PATH_INFO'=>'/'}
  end

  context ".call" do
    context "without matching route" do
      it "should return a 404 status code" do
        Lego::Controller.call(@env)[0].should eql(404)
      end

      it "should return a content type of text/html" do
        Lego::Controller.call(@env)[1].should include('Content-Type'=>'text/html')
      end

      it "should return a body with 404 - Not found" do
        Lego::Controller.call(@env)[2].should eql('404 - Not found')
      end
    end

    context "with matching route" do
      before do
        Lego::Controller.use BasicRouter # Defined in spec/spec_helper.rb
        Lego::Controller.routes.add(:get, '/', &lambda { "hello from lego" })
      end

      it "should return a 200 status code" do
        Lego::Controller.call(@env)[0].should eql(200)
      end

      it "should return a content type of text/html" do
        Lego::Controller.call(@env)[1].should include('Content-Type'=>'text/html')
      end

      it "should return a content length of 15" do
        Lego::Controller.call(@env)[1].should include('Content-Length'=>'15')
      end

      it "should return a body with hello from lego" do
        Lego::Controller.call(@env)[2].body.should eql(['hello from lego'])
      end
    end
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

  it "should respond to instance" do
    Lego::Controller.should respond_to(:instance)
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
