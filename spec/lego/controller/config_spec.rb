require File.join('spec', '/spec_helper')

describe Lego::Controller::Config do

  context ".set options" do

   context "on Lego::Controller" do

     before do
       create_new_app "App1", Lego::Controller
       create_new_app "App2", Lego::Controller
       Lego::Controller.set :foo => "bar"
     end

     it "should be accessible to Lego::Controller" do
       Lego::Controller.current_config.options(:foo).should eql("bar")
     end

     it "should be accessible to App1" do
       App1.current_config.options(:foo).should eql("bar")
     end

     it "should be accessible to App2" do
       App2.current_config.options(:foo).should eql("bar")
     end

     after do
       rm_const "App1", "App2"
     end
   end

   context "on Lego::Controller subclasses" do

     before do
       create_new_app "App1", Lego::Controller
       create_new_app "App2", Lego::Controller
       App1.set :app1 => "App1"
     end

     it "should be available to App1" do
       App1.current_config.options(:app1).should eql("App1")
     end

     it "should NOT be available to App2" do
       App2.current_config.options(:app1).should eql(nil)
     end

     it "should NOT be available to Lego::Controller" do
       App2.current_config.options(:app1).should eql(nil)
     end

     after do
       rm_const "App1", "App2"
     end
   end
  end 

  context ".environment [env], &block" do
    
    context "on Lego::Controller" do

      context "without environment" do
        before do
          create_new_app "App1", Lego::Controller
          create_new_app "App2", Lego::Controller
          Lego::Controller.environment do
            set :bar => "baz"
          end
        end

        it "should be available to Lego::Controller" do
          Lego::Controller.current_config.options(:bar).should eql("baz")
        end

        it "should be available to App1" do
          App1.current_config.options(:bar).should eql("baz")
        end

        it "should be available to App1" do
          App2.current_config.options(:bar).should eql("baz")
        end

        after do
          rm_const "App1", "App2"
        end
      end

      context "with environment" do
        
        before do
          create_new_app "App1", Lego::Controller
          Lego::Controller.environment(:development) { set :current_env => "development" }
          Lego::Controller.environment(:production)  { set :current_env => "production"  }
        end

        it "should default to development" do
          Lego::Controller.current_config.options(:current_env).should eql("development")
        end

        it 'should use ENV["RACK_ENV"] if available' do
          ENV['RACK_ENV'] = 'production'
          Lego::Controller.current_config.options(:current_env).should eql("production")
          ENV['RACK_ENV'] = nil
        end

        it "should be available to subclasses" do
          App1.current_config.options(:current_env).should eql("development")
        end

        after do
          rm_const "App1"
        end
      end
    end

    context "on App1" do

      context "without environment" do

        before do
          create_new_app "App1", Lego::Controller
          create_new_app "App2", Lego::Controller
          App1.environment { set :my_var => "foo" }
        end

        it "should be available to App1" do
          App1.current_config.options(:my_var).should eql("foo")
        end

        it "should not be available to App2" do
          App2.current_config.options(:my_var).should eql(nil)
        end

        after do
          rm_const "App1", "App2"
        end
      end

      context "with environment" do

        before do
          create_new_app "App1", Lego::Controller
          create_new_app "App2", Lego::Controller
          App1.environment(:development) { set :my_env => "development" }
          App1.environment(:production)  { set :my_env => "production"  }
        end

        it "should default to development" do
          App1.current_config.options(:my_env).should eql("development")
        end

        it "should use ENV['RACK_ENV'] if available" do
          ENV['RACK_ENV'] = 'production'
          App1.current_config.options(:my_env).should eql("production")
          ENV['RACK_ENV'] = nil
        end

        it "should not be available to App2" do
          App2.current_config.options(:my_env).should eql(nil)
        end

        it "should not be available to Lego::Controller" do
          Lego::Controller.current_config.options(:my_env).should eql(nil)
        end

        after do
          rm_const "App1", "App2"
        end
      end
    end
  end

  context ".options key" do

    before do
      clean_config! Lego::Controller
      Lego::Controller.set :my_symbol  => "my_symbol",
                           "my_string" => "my_string"
    end

    it "should allow string acces to symbol keys" do
      Lego::Controller.current_config.options("my_symbol").should eql("my_symbol")
    end

    it "should allow symbol acces to string keys" do
      Lego::Controller.current_config.options(:my_string).should eql("my_string")
    end
  end
end

def clean_config!(*consts)
  consts.each do |const|
    const::Config.class_eval "remove_instance_variable :@config if @config"
    const::Config.class_eval "remove_instance_variable :@env    if @env   "
  end
end
