require File.join(Dir.pwd, 'spec', 'spec_helper')

context "LegoController" do

  it "should set up a unique instance of self for subclasses" do
    app1 = Class.new(Lego::Controller)
    app2 = Class.new(Lego::Controller)
    app1.controller_instance.should_not eql(app2.controller_instance)
  end

  context "When a method is added" do

    it "should add a class level proxy method" do
      Lego::Controller.class_eval { def foo; "foo"; end }
      Lego::Controller.foo.should eql("foo")
    end

    it "should add a class level proxy with args" do
      Lego::Controller.class_eval do
        def foo(bar, baz)
          "#{bar} - #{baz}"
        end
      end

      Lego::Controller.foo("bar", "baz").should eql("bar - baz")
    end

    it "should add a class level proxy with a block" do
      Lego::Controller.class_eval do
        def foo(&block)
          "#{block.call}"
        end
      end

      Lego::Controller.foo { "foobar"  }.should eql("foobar")
    end

    it "should add a class level proxy with arbitrary args and a block" do
      Lego::Controller.class_eval do
        def foo(*args, &block)
          "#{args.inspect} - #{block.call}"
        end
      end
           
      Lego::Controller.foo("foo", "bar") { 
        "foobar"  
      }.should eql("[\"foo\", \"bar\"] - foobar")
    end

    it "should make controller methods available to subclasses as well" do
      Lego::Controller.class_eval do
        def foobar
          "foo"
        end
      end
      app1 = Class.new(Lego::Controller)
      app2 = Class.new(Lego::Controller)
      
      app1.foobar.should eql("foo")
      app2.foobar.should eql("foo")
    end

    it "should not share methods between subclasses" do
      app1 = Class.new(Lego::Controller)
      app2 = Class.new(Lego::Controller)
      app1.class_eval { def foobar;"app1";end }
      app2.class_eval { def foobar;"app2";end }
      
      app1.foobar.should_not eql(app2.foobar)
    end
  end

  context ".routes" do
    
    context "instance level" do
      it "should return a routes instance" do
        app = Class.new(Lego::Controller)
        app.controller_instance.routes.is_a?(Lego::Controller::Routes).should eql(true)
      end

      it "should be unique to Lego::Controller subclasses" do
        app1 = Class.new(Lego::Controller)
        app2 = Class.new(Lego::Controller)

        app1.controller_instance.routes.should_not eql(app2.controller_instance.routes)
      end

    end

    context "class level" do
      it "should return a routes instance" do
        app = Class.new(Lego::Controller)
        app.routes.is_a?(Lego::Controller::Routes).should eql(true)
      end
    end

    context "matchers" do
      let(:matcher)    { Module.new                  }
      let(:controller) { Lego::Controller            }
      let(:app1)       { Class.new(Lego::Controller) }
      let(:app2)       { Class.new(Lego::Controller) }

      before do
        controller.controller_instance.routes.matchers.clear
      end

      it "should inherit matchers from Lego::Controller" do
        controller.controller_instance.routes.matchers << matcher
        app1.new.routes.matchers.should eql([matcher])
      end

      it "should not share matchers between subclasses" do
        app1.controller_instance.routes.matchers << matcher
        app1_matchers = app1.controller_instance.routes.matchers
        app1_matchers.should_not eql(app2.controller_instance.routes.matchers)
      end
    end
  end

  context ".call <env>" do

    context "with defined routes" do
      let(:matcher) do 
        Module.new do 
          def self.match_route(routes, verb, path)
            routes[verb][path]
          end
        end
      end

      before do
        Lego::Controller.controller_instance.routes.matchers << matcher
        Lego::Controller.controller_instance.routes.add :get, '/', &lambda { "root" }
        @response = Lego::Controller.call({'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'})
      end

      it "should return a three element array" do
        @response.length.should eql(3)
      end

      context "response" do
        
        it "should be a 200" do
          @response[0].should eql(200)
        end

        it "should have a content type and length" do
          @response[1].should eql({"Content-Type"=>"text/html", "Content-Length"=>"4"})
        end

        it "should have a body" do
          @response[2].body.should eql(["root"])
        end
      end
    end

    context "without defined routes" do
      before do
        @response = Lego::Controller.call({'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/404'})
      end

      it "should return a three element array" do
        @response.length.should eql(3)
      end

      context "response" do
        
        it "should be a 200" do
          @response[0].should eql(404)
        end

        it "should have a content type and length" do
          @response[1].should eql({'Content-Type'=>'text/html', 'Content-Length'=>'9'})
        end

        it "should have a body" do
          @response[2].should eql(["Not Found"])
        end
      end
    end
  end

  context "plugins" do

    context "controller plugin" do
      
      before do
        plugin = Module.new do
          def self.register(lego)
            lego.register_plugin :controller, self
          end

          def get(path, &block)
            routes.add :get, path, &block
          end
        end
        @app = Class.new(Lego::Controller) 
        @app.controller_instance.plugin plugin
      end

      it "should make plugin method accessible" do
        @app.get("/", &lambda { "controller plugin" })

        @app.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[0].should eql(200)
      end
    end

    context "helper plugin" do
      
      before do
        helper_plugin = Module.new do
          def self.register(lego)
            lego.register_plugin :helper, self
          end

          def h(content)
            Rack::Utils.escape(content)
          end
        end
        controller_plugin = Module.new do
          def self.register(lego)
            lego.register_plugin :controller, self
          end

          def get(path, &block)
            routes.add :get, path, &block
          end
        end
        Lego::Controller.controller_instance.plugin controller_plugin
        @app1 = Class.new(Lego::Controller) 
        @app2 = Class.new(Lego::Controller)
        @app1.plugin helper_plugin
      end

      it "should make plugin method accessible" do
        @app1.get("/", &lambda { h("<html>") })

        @app1.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[2].body.should eql(["%3Chtml%3E"])
      end

      it "should not share methods between subclasses" do
        @app2.get("/", &lambda { h("<html>") })

        @app2.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[2].body.should eql(["%3Chtml%3E"])
      end
    end

    context "router plugin" do
      
      before do
        Lego::Controller.controller_instance.routes.matchers.clear
        router_plugin = Module.new do
          def self.register(lego)
            lego.register_plugin :router, self
          end

          def self.match_route(router, verb, path)
            router[verb][path]
          end
        end
        controller_plugin = Module.new do
          def self.register(lego)
            lego.register_plugin :controller, self
          end

          def get(path, &block)
            routes.add :get, path, &block
          end
        end
        Lego::Controller.controller_instance.plugin controller_plugin
        @app1 = Class.new(Lego::Controller) 
        @app2 = Class.new(Lego::Controller)
        @app1.controller_instance.plugin router_plugin
      end

      it "should make plugin method accessible" do
        @app1.get("/", &lambda { "router plugin" })

        @app1.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[2].body.should eql(["router plugin"])
      end

      it "should not share methods between subclasses" do
        @app2.get("/", &lambda { "router plugin" })

        @app2.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[2].should eql(["Not Found"])
      end
    end
  end
end
