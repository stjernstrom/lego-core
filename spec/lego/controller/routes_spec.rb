require File.join(Dir.pwd, 'spec', 'spec_helper')

context "Lego::Controller::Routes" do
  
  context ".get <verb>, <path>, <proc>" do

    before do
      @routes = Lego::Controller::Routes.new
      @routes.matchers << Module.new do
        def self.match_route(routes, verb, path)
          routes[verb][path]
        end
      end
      @routes.add(:get, "/", &lambda { "root path" })
    end

    it "should be able to get added routes" do
      @routes.get(:get, "/").call.should eql("root path") 
    end
  end

  context ".matchers" do

    let(:routes)  { Lego::Controller::Routes.new }
    let(:matcher) { Module.new }

    it "should exist" do
      routes.should respond_to(:matchers)
    end

    it "should hold an array of matchers" do
      routes.matchers << matcher
      routes.matchers.should eql([matcher])
    end
  end
end
