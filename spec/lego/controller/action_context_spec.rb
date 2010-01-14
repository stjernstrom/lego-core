require File.join('spec', '/spec_helper')

describe Lego::Controller::ActionContext do

  context 'generates rack response from @response hash' do
    before do
      @instance = Lego::Controller::ActionContext.new
    end

    it 'should set the current message body' do
      @instance.response[:body] = "Hello again"
      @instance.run([{},nil, {}]).should eql([ 200, {"Content-Type"=>"text/html"}, 'Hello again' ])
    end

    it 'should set response headers' do
      @instance.response[:headers] = {'Content-Type' => 'cust/head'}
      @instance.run([{},nil, {}]).should eql([ 200, {"Content-Type"=>"cust/head"}, '' ])
    end

    it 'should set response code' do
      @instance.response[:code] = 666 
      @instance.run([{},nil,{}]).should eql([ 666, {"Content-Type"=>"text/html"}, '' ])
    end
  end

  context '.run instance method' do
    before do
      @instance = Lego::Controller::ActionContext.new
      @env = []
    end

    it 'should have a default Rack response' do
      @instance.run(["", @env, {}]).should eql([200, {'Content-Type' => 'text/html'} , ''])
    end

    it 'should evaluate :action_block in instance if exists in route' do
      route = { :action_block => Proc.new{ "Hello my world!" }}
      @instance.run([route, @env, {}]).should eql([200, {'Content-Type' => 'text/html'} , "Hello my world!" ])
    end

    it 'should convert route[:instance_vars] to instance variables' do
      route = {}
      match_data = { :instance_vars => { :myvar => "This is my var" } }
      @instance.run([route, @env, match_data]).should eql([200, {'Content-Type' => 'text/html'} , '' ])
      @instance.instance_variable_get(:@myvar).should eql("This is my var")
    end

    it 'should set response[:code] if set_response_route is set in route' do
      route = {}
      route_match = { :set_response_code => 666 }
      @instance.run([route, @env, route_match]).should eql([666, {'Content-Type' => 'text/html'} , '' ])
    end
  end

  context ".options helper method" do
    before do
      create_new_app "App", Lego::Controller
      Lego::Controller::ActionContext::ApplicationClass = App
      @instance = Lego::Controller::ActionContext.new
      @env = []
    end

    it 'should evaluate :action_block in instance if exists in route' do
      Lego::Controller.set :foo => "bar"
      route = { :action_block => Proc.new{ options(:foo) }}
      @instance.run([route, @env, {}]).should eql([200, {'Content-Type' => 'text/html'} , "bar" ])
    end

    after do
      rm_const "App"
    end
  end

  context 'setting up vars from match_data' do
    before do
      @inst = Lego::Controller::ActionContext.new
      @hash_var = { :fly => "away", :go => "home" }
      @match_data = [{}, {}, { :instance_vars => { :foo => "bar", :params => @hash_var } } ]
    end
    
    it 'should setup @foo instance variable' do
      @inst.run(@match_data)
      @inst.instance_variable_get(:@foo).should eql("bar")
    end

    it 'should setup @params instance variable hash' do
      @inst.run(@match_data)
      @inst.instance_variable_get(:@params).should eql( @hash_var )
    end
  end
end

