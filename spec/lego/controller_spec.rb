require File.join(Dir.pwd, 'spec', 'spec_helper')

context "LegoController" do

  it "should set up a unique instance of self for subclasses" do
    app1 = Class.new(Lego::Controller)
    app2 = Class.new(Lego::Controller)
    app1.controller_instance.should_not eql(app2.controller_instance)
  end

  context ".routes" do
    
    context "instance level" do
      it "should return a routes instance" do
        app = Class.new(Lego::Controller)
        app.routes.is_a?(Lego::Controller::Routes).should eql(true)
      end

      it "should be unique to Lego::Controller subclasses" do
        app1 = Class.new(Lego::Controller)
        app2 = Class.new(Lego::Controller)

        app1.routes.should_not eql(app2.controller_instance.routes)
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
        controller.routes.matchers.clear
      end

      it "should inherit matchers from Lego::Controller" do
        controller.routes.matchers << matcher
        app1.new.routes.matchers.should eql([matcher])
      end

      it "should not share matchers between subclasses" do
        app1.routes.matchers << matcher
        app1_matchers = app1.routes.matchers
        app1_matchers.should_not eql(app2.routes.matchers)
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
        Lego::Controller.routes.matchers << matcher
        Lego::Controller.routes.add :get, '/', &lambda { "root" }
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
        @app1 = Class.new(Lego::Controller) 
        @app2 = Class.new(Lego::Controller) 
        @app1.plugin plugin
      end

      it "should make plugin method accessible" do
        @app1.get("/", &lambda { "controller plugin" })

        @app1.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[0].should eql(200)
      end

      it "should not share methods between subclasses" do
        lambda { 
          @app2.get("/", &lambda { "controller plugin" })
        }.should raise_error(NoMethodError)
      end
    end

    context "view plugin" do
      
      before do
        view_plugin = Module.new do
          def self.register(lego)
            lego.register_plugin :view, self
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
        Lego::Controller.plugin controller_plugin
        @app1 = Class.new(Lego::Controller) 
        @app2 = Class.new(Lego::Controller)
        @app1.plugin view_plugin
      end

      it "should make plugin method accessible" do
        @app1.get("/", &lambda { h("<html>") })

        @app1.controller_instance.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[2].body.should eql(["%3Chtml%3E"])
      end

      it "should not share methods between subclasses" do
        @app2.get("/", &lambda { h("<html>") })

        lambda { 
          @app2.call({'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'})
        }.should raise_error(NoMethodError)
      end
    end

    context "router plugin" do
      
      before do
        Lego::Controller.routes.matchers.clear
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
        Lego::Controller.plugin controller_plugin
        @app1 = Class.new(Lego::Controller) 
        @app2 = Class.new(Lego::Controller)
        @app1.plugin router_plugin
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

    context "global plugins" do
      
      before do
        Lego::Controller.routes.matchers.clear
        plugin = Module.new do
          def self.register(lego)
            lego.register_plugin :view,       ViewPlugin
            lego.register_plugin :router,     RouterPlugin
            lego.register_plugin :controller, ControllerPlugin
          end
          module ViewPlugin
            def h(content)
              Rack::Utils.escape(content)
            end
          end
          module RouterPlugin 
            def self.match_route(router, verb, path)
              router[verb][path]
            end
          end
          module ControllerPlugin
            def get(path, &block)
              routes.add :get, path, &block
            end
          end
        end
        Lego::Controller.plugin plugin
        @app1 = Class.new(Lego::Controller) 
        @app2 = Class.new(Lego::Controller)
      end

      it "plugin methods should be available to ap1" do
        @app1.get("/", &lambda { h("<html>") })

        @app1.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[2].body.should eql(["%3Chtml%3E"])
      end

      it "plugin methods should be available to ap2" do
        @app2.get("/", &lambda { h("<html>") })

        @app2.call({
          'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>'/'
        })[2].body.should eql(["%3Chtml%3E"])
      end
    end
  end
end
