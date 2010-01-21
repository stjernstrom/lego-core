require File.join(Dir.pwd, 'spec', 'spec_helper')

context "Lego::Controller::Context" do

  it "should not be shared with controller subclasses" do
    app = Class.new(Lego::Controller)

    Lego::Controller::Context.object_id.should_not eql(app::Context.object_id)
  end

  it "should not be shared between controller subclasses" do
    app1 = Class.new(Lego::Controller)
    app2 = Class.new(Lego::Controller)

    app1::Context.object_id.should_not eql(app2::Context.object_id)
  end

  context ".finish <env>" do
    context "with empty env" do

      before do
        app = Class.new(Lego::Controller)
        context = app::Context.new

        @response = context.finish({}, &lambda { "" })
      end

      it "should return a 3-element array" do
        @response.length.should eql(3)
      end

      context "response" do
        it "should contain the response code" do
          @response[0].should eql(200)
        end

        it "should contain http headers" do
          @response[1].should eql({"Content-Type"=>"text/html", "Content-Length"=>"0"})
        end

        it "should contain a response body" do
          @response[2].body.should eql([""])
        end
      end
    end

    context "with a lambda" do
      
      context "response" do

        it "should contain lambda content" do
          app     = Class.new(Lego::Controller)
          context = app::Context.new

          context.finish({}, &lambda { 'hello' })[2].body.should eql(["hello"])
        end
      end
    end
  end

  context ".response" do
    
    before do
      app     = Class.new(Lego::Controller)
      @context = app::Context.new

      @context.finish({}, &lambda { 'hello' })
    end

    it "should return a Rack::Response object" do
      @context.response.is_a?(Rack::Response)
    end

    it "should contain a body" do
      @context.response.body.should eql(["hello"])
    end
  end

  context ".request" do
    
    before do
      app     = Class.new(Lego::Controller)
      @context = app::Context.new

      @context.finish({}, &lambda { 'hello' })
    end

    it "should return a Rack::Response object" do
      @context.request.is_a?(Rack::Response)
    end

    it "should contain a body" do
      @context.response.body.should eql(["hello"])
    end
  end
end 
