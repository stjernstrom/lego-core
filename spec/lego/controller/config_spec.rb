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
        clean_config! Lego::Controller
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
        clean_config! Lego::Controller, App1, App2
        rm_const "App1", "App2"
      end
    end
  end 

  context ".config" do
    
    before do
      Lego::Controller.set :foo => "bar",
                           :baz => "quux"
    end

    it "should contain the newly set options" do
      Lego::Controller.current_config.config.should eql({"foo"=>"bar","baz"=>"quux"})
    end

    after do
      clean_config! Lego::Controller
    end
  end

  context ".options key" do

    before do
      Lego::Controller.set :my_symbol  => "my_symbol",
                           "my_string" => "my_string"
    end

    it "should allow string acces to symbol keys" do
      Lego::Controller.current_config.options("my_symbol").should eql("my_symbol")
    end

    it "should allow symbol acces to string keys" do
      Lego::Controller.current_config.options(:my_string).should eql("my_string")
    end

    after do
      clean_config! Lego::Controller
    end
  end
end

def clean_config!(*consts)
  consts.each do |const|
    const::Config.class_eval "remove_instance_variable :@config if @config"
    const::Config.class_eval "remove_instance_variable :@env    if @env   "
  end
end
