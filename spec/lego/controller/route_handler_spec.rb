require File.join('spec', '/spec_helper')

describe Lego::Controller::RouteHandler do

  context '.match_all_routes with matching route' do
    before do
      @route_handler = empty_route_handler
      @env = {}
      @env["REQUEST_METHOD"] = 'GET'
      @valid_route = {:path => '/myadmin'}
      @other_route = {:path => '/foo'}
      @fake_routes = {:get => [@other_route, @other_route, @valid_route], :post => [{}]}
    end
    
    it 'should return Array matching route found' do
      @route_handler.should_receive(:routes).and_return(@fake_routes)
      @route_handler.should_receive(:run_matchers).with(@other_route, @env).exactly(2).times.and_return(false)
      @route_handler.should_receive(:run_matchers).with(@valid_route, @env).and_return(true)
      @route_handler.match_all_routes(@env).should eql(@valid_route)
    end
    
    it 'should return false when no matching route is found' do
      @route_handler.should_receive(:routes).and_return({:get=> [{}]})
      @route_handler.should_receive(:run_matchers).and_return(false)
      @route_handler.match_all_routes(@env).should eql(nil)
    end
  end

  context '.run_matchers' do
    before do
      @route_handler = empty_route_handler
      @env = {}
      @route = { :path => '/mypath' } 
      module Match1; end
      module Match2; end
      @matchers = [Match1, Match2]
    end
    
    it 'should return Array when matching route found' do
      Match1.should_receive(:match_route).with(@route, @env).and_return(false)
      Match2.should_receive(:match_route).with(@route, @env).and_return([@route, @env, [ :var => "a var"]])
      @route_handler.should_receive(:matchers).and_return(@matchers)
      @route_handler.run_matchers(@route, @env).should eql([@route, @env, [ :var => "a var"]])
    end
    
    it 'should return false when no matching route found' do
      Match1.should_receive(:match_route).with(@route, @env).and_return(false)
      Match2.should_receive(:match_route).with(@route, @env).and_return(false)
      @route_handler.should_receive(:matchers).and_return(@matchers)
      @route_handler.run_matchers(@route, @env).should eql(false)
    end
  end

  context '.routes' do
    before do
      @route_handler = empty_route_handler
    end

    it 'should return empty routes when new' do
      @route_handler.routes.should eql({
        :get       => [],
        :post      => [],
        :put       => [],
        :head      => [],
        :delete    => [],
        :not_found => nil
      })
    end
  end

  context '.add_route' do
    before do
      @route_handler = empty_route_handler
    end

    it 'should appen routes with their options' do
      route_options1 = { :path => '/a_path1' }
      route_options2 = { :path => '/a_path2' }
      @route_handler.add_route(:get, route_options1)
      @route_handler.add_route(:get, route_options2)
      @route_handler.routes[:get].should eql([route_options1, route_options2])
    end

    it 'should set not_found route if method is :not_found' do
      route_options = { :action_block => '{block}' }
      @route_handler.add_route(:not_found, route_options)
      @route_handler.routes[:not_found].should eql(route_options)
    end
  end

  context '.matchers' do
    before do
      @route_handler = empty_route_handler
    end

    it 'should return an empty Array when new' do
      @route_handler.matchers.should eql([])  
    end

  end

  context '.add_matcher' do
    before do
      @route_handler = empty_route_handler
      module ValidMatcher; def self.match_route(route, env); end; end
      module BrokenMatcher; end
    end

    it 'should store route matchers if valid' do
      @route_handler.add_matcher(ValidMatcher)
      @route_handler.matchers.should eql([ValidMatcher])
    end
    
    it 'should raise InvalidMatcher error if invalid' do
      @route_handler.should_receive(:validate_matcher).and_return(false)
      lambda { @route_handler.add_matcher(BrokenMatcher) }.should raise_error(Lego::Controller::RouteHandler::InvalidMatcher)
      @route_handler.matchers.should == []
    end
  end

  context '.validate_matcher' do
    before do
      @route_handler = empty_route_handler
      module MyBrokenMatcher; end
      module MyValidMatcher; def self.match_route(); end; end
    end
    
    it 'should return true if a valid Matcher module' do
      @route_handler.validate_matcher(MyValidMatcher).should be_true
    end

    it 'should return false if not a valid Matcher module' do
      @route_handler.validate_matcher(MyBrokenMatcher).should be_false
    end
  end

  context 'when extended' do
    before do
      reset_lego_base
    end
    it 'plugins should be copied from base class' do

      module GlobalPlug
        def self.register(lego)
          lego.add_plugin :router, self
        end

        def another_routehandler 
          add_route(:get, {})
        end

        def self.match_route(route, env); end
      end

      # Create two fake plugins
      Object.const_set(:App1Plug, GlobalPlug.clone)
      Object.const_set(:App2Plug, GlobalPlug.clone)

      Lego.plugin GlobalPlug

      create_new_app("MyApp1", Lego::Controller)
      create_new_app("MyApp2", Lego::Controller)

      MyApp1.plugin App1Plug
      MyApp2.plugin App2Plug

      Lego::Controller::RouteHandler.matchers.should eql([GlobalPlug])
      MyApp1::RouteHandler.matchers.should eql([GlobalPlug, App1Plug])
      MyApp2::RouteHandler.matchers.should eql([GlobalPlug, App2Plug])
    end

    after do
      rm_const "GlobalPlug", "App1Plug", "App2Plug", "MyApp1", "MyApp2"
    end
  end

end

def empty_route_handler
  route_handler = Lego::Controller::RouteHandler.clone
  route_handler.class_eval "remove_instance_variable :@route_cache if @route_cache"
  route_handler.class_eval "remove_instance_variable :@matcher_cache if @matcher_cache"
  route_handler
end




